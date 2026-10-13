import Foundation
import Observation

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
    private var autoReconnect = false
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

    public func connect(allowFirstUseTrust: Bool = true) {
        guard !connecting else { return }
        guard HostAddress.isLocalIPv4(identity.host) else {
            error = "Enter the TV's local IPv4 address or discover a TV on your network."
            return
        }
        autoReconnect = true
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
        client.onPairing = { [weak self] in self?.pairing = true }
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
            if !self.connecting {
                self.notice = "Connection lost. Reconnecting…"
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
                self.error = "\(error.localizedDescription) Make sure the TV is on and on the same Wi-Fi network."
                self.log("Connection failed", error.localizedDescription)
                if allowFirstUseTrust { self.autoReconnect = false }
                self.scheduleReconnect()
            }
        }
    }

    public func disconnect(stopReconnect: Bool = true) {
        pauseUsage()
        remote.cancelPointer()
        cast.stopPlayback()
        if stopReconnect { autoReconnect = false }
        connectTask?.cancel()
        reconnectTask?.cancel()
        refreshTask?.cancel()
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

    private func scheduleReconnect() {
        guard autoReconnect else { return }
        reconnectTask?.cancel()
        reconnectTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            if !Task.isCancelled { self?.connect(allowFirstUseTrust: false) }
        }
    }
}
