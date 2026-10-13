import Foundation
import Observation

@MainActor
@Observable
public final class RemoteCoordinator {
    public let identity: TVIdentity
    public let session: TVSession
    public let catalog: TVCatalog
    public let volume: VolumeController
    public let remote: RemoteController
    public let picture: PictureController
    public let cast: CastSession
    public let activity: ActivityLog
    public let usage: UsageTracker
    public private(set) var discovering = false
    public private(set) var devices: [TVDevice] = []

    public init(defaults: UserDefaults = .standard, supportDirectory: URL = AppSupport.directory()) {
        identity = TVIdentity(defaults: defaults)
        activity = ActivityLog(directory: supportDirectory)
        usage = UsageTracker(directory: supportDirectory)
        catalog = TVCatalog(defaults: defaults)
        volume = VolumeController()
        remote = RemoteController(catalog: catalog)
        picture = PictureController()
        cast = CastSession()
        session = TVSession(
            identity: identity,
            catalog: catalog,
            volume: volume,
            remote: remote,
            picture: picture,
            cast: cast,
            usage: usage,
            activity: activity
        )
        volume.commands = session
        remote.commands = session
        catalog.commands = session
        catalog.remote = remote
        picture.commands = session
        cast.commands = session
        remote.onHomeSent = { [weak self] in self?.usage.pause() }
        activity.onFailure = { [weak self] message in self?.session.notice = message }
        usage.onFailure = { [weak self] message in self?.session.notice = message }
    }

    public var homeRequested: Bool { remote.homeRequested }
    public var displayForegroundID: String { homeRequested ? "com.webos.app.home" : remote.foregroundID }
    public var currentInput: TVInput? {
        homeRequested ? nil : catalog.inputs.first { $0.appID == remote.foregroundID }
    }
    public var currentAppTitle: String {
        if homeRequested { return "Home menu" }
        if !remote.foregroundName.isEmpty { return remote.foregroundName }
        return session.connected ? "TV is on" : ""
    }
    public var statusText: String {
        if session.pairing { return "Accept the connection on your TV" }
        if session.connecting { return "Connecting…" }
        return session.connected ? "Connected" : "Disconnected"
    }
    public var orderedInputs: [TVInput] { catalog.orderedInputs(activeID: displayForegroundID) }
    public var mostUsedApps: [TVApp] { usage.mostUsed(apps: catalog.apps, host: identity.host) }

    public func connect(allowFirstUseTrust: Bool = true) { session.connect(allowFirstUseTrust: allowFirstUseTrust) }
    public func disconnect() { session.disconnect() }

    public func discover() {
        guard !discovering else { return }
        discovering = true
        session.error = nil
        Task { [weak self] in
            let found = await TVDiscovery.search()
            guard let self else { return }
            devices = found
            discovering = false
            if found.isEmpty { session.notice = "No TV found. Turn on your TV or enter its IP address below." }
        }
    }

    public func select(_ tv: TVDevice) {
        session.disconnect()
        identity.host = tv.host
        identity.name = tv.name
        identity.model = tv.model
        identity.mac = tv.mac ?? ""
        session.connect()
    }

    public func refresh() async {
        await session.refresh()
        await picture.refresh()
    }

    public func power() {
        if session.connected {
            session.perform { [weak self] client in
                _ = try await client.request(SSAP.Power.turnOff)
                self?.session.disconnect()
                self?.session.notice = "TV turned off."
            }
        } else {
            do {
                try TVDiscovery.wake(mac: identity.mac, host: identity.host)
                session.notice = "Wake signal sent. Enable Wi-Fi wake on the TV first."
            } catch {
                session.error = error.localizedDescription
            }
        }
    }

    public func setAdvancedControls(_ enabled: Bool) async {
        guard identity.advancedControls != enabled else { return }
        let previous = identity.advancedControls
        identity.advancedControls = enabled
        identity.save()
        let host = identity.host
        guard !host.isEmpty else { return }
        session.disconnect()
        do {
            try await Task.detached(priority: .userInitiated) { try PairingKey.deleteKey(host) }.value
        } catch {
            identity.advancedControls = previous
            identity.save()
            session.error = "Could not update pairing: \(error.localizedDescription)"
            return
        }
        session.notice = enabled
            ? "Advanced controls need a new pairing. Accept the prompt on the TV."
            : "Basic control needs a new pairing. Accept the prompt on the TV."
        session.connect()
    }

    public func forgetPairing() async {
        guard !identity.host.isEmpty else { return }
        let pairingHost = identity.host
        session.disconnect()
        do {
            try await Task.detached(priority: .userInitiated) { try PairingKey.delete(pairingHost) }.value
            session.notice = "Saved pairing removed. Connect to pair this TV again."
        } catch {
            session.error = "Could not remove saved pairing: \(error.localizedDescription)"
        }
    }

    /// iOS suspends the process in the background. Pause local usage and reconnect without a new trust prompt.
    public func pauseForBackground() { session.pauseUsage() }

    public func resumeAfterForeground() {
        guard session.wantsReconnect, !identity.host.isEmpty, !session.connecting, !session.connected else { return }
        session.connect(allowFirstUseTrust: false)
    }
}
