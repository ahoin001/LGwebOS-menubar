import Foundation
import Observation

public enum TVReach: Equatable {
    case unknown
    /// Saved pairing, TV is not answering. The phone did not drop the pairing.
    case off
    case waking
    /// The user stopped controlling the TV. It may still be on.
    case held
}

@MainActor
@Observable
public final class TVSession: TVCommanding {
    public private(set) var connected = false
    public private(set) var connecting = false
    public private(set) var pairing = false
    public var error: String?
    public var notice: String?
    public private(set) var firmware = ""
    public private(set) var webOS = ""
    public private(set) var reach: TVReach = .unknown
    public var onCertificateTrust: (@MainActor (String, String) async -> Bool)?
    public var wantsReconnect: Bool { autoReconnect }

    private let identity: TVIdentity
    private let catalog: TVCatalog
    private let volume: VolumeController
    private let remote: RemoteController
    private let picture: PictureController
    private let cast: CastSession
    private let usage: UsageTracker
    private let activity: ActivityLog
    private var connection: WebOSConnection?
    private var connectTask: Task<Void, Never>?
    private var reconnectTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    private var wakeTask: Task<Void, Never>?
    private var autoReconnect = false
    private var retryUnreachable = true
    private var wakeDeadline: Date?
    private var powerActive = false

    var isConnected: Bool { connected }
    var client: WebOSConnection? { connection }
    var tvHost: String { identity.host }

    init(
        identity: TVIdentity,
        catalog: TVCatalog,
        volume: VolumeController,
        remote: RemoteController,
        picture: PictureController,
        cast: CastSession,
        usage: UsageTracker,
        activity: ActivityLog
    ) {
        self.identity = identity
        self.catalog = catalog
        self.volume = volume
        self.remote = remote
        self.picture = picture
        self.cast = cast
        self.usage = usage
        self.activity = activity
    }

    public func connect(allowFirstUseTrust: Bool = true, retryUnreachable: Bool = true) {
        guard !connecting else { return }
        self.retryUnreachable = retryUnreachable
        reconnectTask?.cancel()
        guard HostAddress.isLocalIPv4(identity.host) else {
            error = "Enter the TV's local IPv4 address or discover a TV on your network."
            log("Connection failed", identity.host.isEmpty
                ? "No TV address is saved."
                : "\(identity.host) is not a local IPv4 address. IPv6 addresses and hostnames are not accepted.")
            return
        }
        autoReconnect = retryUnreachable
        error = nil
        connecting = true
        pairing = false
        pauseUsage()
        remote.dismissHome()
        connection?.close()
        refreshTask?.cancel()
        remote.markPointer(false)
        let client = WebOSConnection(host: identity.host)
        connection = client
        client.onCertificateTrust = { [weak self] host, fingerprint in
            await self?.onCertificateTrust?(host, fingerprint) ?? false
        }
        client.onPairing = { [weak self] in
            self?.pairing = true
            self?.log("Pairing prompt", "The TV is asking you to accept LG Remote App.")
        }
        client.onEvent = { [weak self] title, detail in self?.log(title, detail) }
        client.onPointerState = { [weak self, weak client] ready in
            guard let self, self.connection === client else { return }
            self.remote.markPointer(ready)
        }
        client.onDisconnect = { [weak self, weak client] failure in
            guard let self, self.connection === client else { return }
            self.connected = false
            self.remote.markPointer(false)
            self.volume.reset()
            self.remote.cancelPointer()
            self.remote.dismissHome()
            self.pauseUsage()
            self.log("Connection lost", failure.localizedDescription)
            if self.reach == .held { return }
            let keepTrying = self.autoReconnect && self.reach != .off
            if self.reach != .waking { self.reach = .off }
            if !self.connecting, keepTrying {
                self.notice = nil
                self.scheduleReconnect()
            }
        }
        connectTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await client.connect(allowFirstUseTrust: allowFirstUseTrust)
                guard self.connection === client else { return }
                self.connected = true
                self.connecting = false
                self.pairing = false
                self.autoReconnect = true
                self.reach = .unknown
                self.wakeDeadline = nil
                self.notice = nil
                self.log("Connected", "\(self.identity.name) · \(self.identity.host)")
                if let system = try? await client.request(SSAP.System.info), let detected = SSAPPayload.modelName(system) {
                    self.identity.model = detected
                }
                self.identity.save()
                await self.refresh()
                try? await client.subscribe(SSAP.Audio.getVolume) { [weak self] payload in self?.volume.apply(payload) }
                try? await client.subscribe(SSAP.Launcher.foreground) { [weak self] payload in self?.applyForeground(payload) }
                if let info = try? await client.request(SSAP.System.software) {
                    let software = SSAPPayload.software(info)
                    self.firmware = software.firmware
                    self.webOS = software.product
                }
                await self.picture.refresh(client)
                do {
                    try await client.checkPointer()
                    self.log("Remote ready", "Navigation connection is ready and verified.")
                } catch {
                    self.log("Remote unavailable", error.localizedDescription)
                }
                self.refreshTask = Task { [weak self] in
                    while !Task.isCancelled {
                        try? await Task.sleep(nanoseconds: 20_000_000_000)
                        if Task.isCancelled { break }
                        await self?.refreshState()
                    }
                }
            } catch {
                guard self.connection === client else { return }
                client.close()
                self.connected = false
                self.connecting = false
                self.pairing = false
                if self.reach == .waking, !Self.tvAnswered(error) {
                    if self.wakeWindowExpired {
                        self.log("Connection failed", error.localizedDescription)
                        self.finishWakeUnanswered()
                    } else {
                        self.error = nil
                        self.notice = nil
                        self.watchForWake(pause: 1.5)
                    }
                    return
                }
                self.log("Connection failed", error.localizedDescription)
                if self.reach == .waking {
                    self.reach = .unknown
                    self.wakeDeadline = nil
                    self.autoReconnect = false
                    self.error = error.localizedDescription
                    return
                }
                if Self.isUnreachable(error) {
                    self.noteUnreachable()
                    return
                }
                self.reach = .unknown
                self.wakeDeadline = nil
                self.error = error.localizedDescription
                if allowFirstUseTrust { self.autoReconnect = false }
                else if self.retryUnreachable { self.scheduleReconnect() }
            }
        }
    }

    public func beginWaitingForWake() {
        reach = .waking
        wakeDeadline = Date().addingTimeInterval(20)
        error = nil
        notice = nil
        watchForWake(pause: 2)
    }

    public func markTurnedOff() {
        reach = .off
        wakeDeadline = nil
        error = nil
        notice = nil
        disconnect(stopReconnect: true)
    }

    public func disconnect(stopReconnect: Bool = true, held: Bool = false) {
        if held {
            reach = .held
            wakeDeadline = nil
        } else if stopReconnect, reach == .waking {
            reach = .off
            wakeDeadline = nil
        }
        pauseUsage()
        remote.cancelPointer()
        cast.stopPlayback()
        if stopReconnect { autoReconnect = false }
        connectTask?.cancel()
        reconnectTask?.cancel()
        refreshTask?.cancel()
        wakeTask?.cancel()
        wakeTask = nil
        volume.cancelPending()
        connection?.close()
        connection = nil
        connected = false
        remote.markPointer(false)
        connecting = false
        pairing = false
        volume.reset()
        remote.clearForeground()
        catalog.clearLiveData()
        remote.dismissHome()
    }

    public func refresh() async {
        guard let client = connection, connected else { return }
        await catalog.reload(client)
        await refreshState()
    }

    public func refreshState() async {
        guard let client = connection, connected else { return }
        if let answer = try? await client.request(SSAP.Power.state) {
            powerActive = SSAPPayload.powerIsActive(answer)
        } else {
            powerActive = false
            pauseUsage()
        }
        if let answer = try? await client.request(SSAP.Audio.getVolume) { volume.apply(answer) }
        if let answer = try? await client.request(SSAP.Launcher.foreground) { applyForeground(answer) }
    }

    public func pauseUsage() {
        usage.pause()
        powerActive = false
    }

    public func resetSoftwareIdentity() {
        firmware = ""
        webOS = ""
    }

    func perform(_ action: @escaping (WebOSConnection) async throws -> Void) {
        guard connected, let client = connection else { return }
        error = nil
        Task { [weak self] in
            do { try await action(client) }
            catch {
                self?.error = error.localizedDescription
                self?.log("Command failed", error.localizedDescription)
            }
        }
    }

    func reportError(_ message: String) { error = message }
    func clearError() { error = nil }
    func reportNotice(_ message: String) { notice = message }
    func log(_ title: String, _ detail: String) { activity.log(title, detail) }

    private func applyForeground(_ payload: [String: Any]) {
        remote.noteForeground(payload, host: identity.host, powerActive: powerActive, connected: connected, usage: usage) { [weak self] in
            self?.pauseUsage()
        }
    }

    private var wakeWindowExpired: Bool {
        wakeDeadline.map { Date() >= $0 } ?? true
    }

    /// Poll port 3001 until the TV is listening, then open the real connection. A refused socket while the set is booting is not a failure.
    private func watchForWake(pause: TimeInterval) {
        wakeTask?.cancel()
        let host = identity.host
        wakeTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(pause * 1_000_000_000))
            while !Task.isCancelled {
                guard let self, self.reach == .waking else { return }
                if self.wakeWindowExpired {
                    self.finishWakeUnanswered()
                    return
                }
                if await TVDiscovery.serviceIsReachable(host) {
                    guard !Task.isCancelled, self.reach == .waking else { return }
                    self.connect(allowFirstUseTrust: false)
                    return
                }
                try? await Task.sleep(nanoseconds: 1_500_000_000)
            }
        }
    }

    private func finishWakeUnanswered() {
        reach = .off
        wakeDeadline = nil
        autoReconnect = false
        connecting = false
        error = nil
        notice = "The TV didn't answer. On the TV, turn on Turn on via Wi-Fi."
    }

    private func noteUnreachable() {
        if reach == .waking {
            if wakeWindowExpired { finishWakeUnanswered() }
            return
        }
        reach = .off
        error = nil
        notice = nil
        if retryUnreachable { scheduleReconnect() }
        else { autoReconnect = false }
    }

    private static func tvAnswered(_ error: Error) -> Bool {
        let lower = error.localizedDescription.lowercased()
        return lower.contains("certificate") || lower.contains("pairing") || lower.contains("403") || lower.contains("blacklist") || lower.contains("rejected")
    }

    private static func isUnreachable(_ error: Error) -> Bool {
        let ns = error as NSError
        if ns.domain == NSPOSIXErrorDomain {
            let code = Int32(ns.code)
            return [ECONNREFUSED, ETIMEDOUT, EHOSTUNREACH, EHOSTDOWN, ENETUNREACH, ENETDOWN, ECONNRESET].contains(code)
        }
        if ns.domain == NSURLErrorDomain {
            return [
                NSURLErrorTimedOut,
                NSURLErrorCannotFindHost,
                NSURLErrorCannotConnectToHost,
                NSURLErrorNetworkConnectionLost,
                NSURLErrorDNSLookupFailed,
                NSURLErrorNotConnectedToInternet
            ].contains(ns.code)
        }
        let lower = error.localizedDescription.lowercased()
        return ["could not connect", "timed out", "connection refused", "offline", "network connection was lost", "host is down", "connection closed before it opened"].contains { lower.contains($0) }
    }

    private func scheduleReconnect() {
        guard autoReconnect else { return }
        log("Reconnecting", "Another attempt starts in 5 seconds. Repeated attempts can keep a pairing rejection in place.")
        reconnectTask?.cancel()
        reconnectTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            if !Task.isCancelled { self?.connect(allowFirstUseTrust: false) }
        }
    }
}
