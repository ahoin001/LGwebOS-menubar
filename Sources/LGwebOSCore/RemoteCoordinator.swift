import Foundation
import Observation

public enum TVLinkAction: Equatable {
    case turnOff
    case turnOn
    case connect
    case setUpWake
    case cancel
    case addTV
}

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
        RegistrationRepair.dropPreviousPairingIfNeeded(defaults: defaults, host: identity.host)
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
    public var canWake: Bool { HostAddress.isMAC(identity.mac) }
    public var linkAction: TVLinkAction {
        if session.connecting || session.reach == .waking { return .cancel }
        if session.connected { return .turnOff }
        if session.reach == .held { return .connect }
        if session.reach == .off { return canWake ? .turnOn : .setUpWake }
        if identity.host.isEmpty { return .addTV }
        if canWake { return .turnOn }
        return .connect
    }
    public var linkActionTitle: String {
        switch linkAction {
        case .turnOff: return "Turn off"
        case .turnOn: return "Turn on"
        case .connect: return "Connect"
        case .setUpWake: return "Set up turn on"
        case .cancel: return "Cancel"
        case .addTV: return "Add a TV"
        }
    }
    public var powerTitle: String { session.reach == .waking ? "Waiting" : linkActionTitle }
    public var linkSymbol: String {
        if session.pairing { return "checkmark.shield" }
        if session.reach == .held { return "link" }
        if session.reach == .off || session.reach == .waking || (!session.connected && canWake) { return "power" }
        return "wifi"
    }
    public var connectionDetail: String {
        if session.pairing { return "Accept “LG Remote App” on your TV." }
        if session.reach == .waking { return "This can take a minute. Leave the app open." }
        if session.error != nil, !session.connecting, !session.connected { return "The TV did not accept the connection." }
        if session.reach == .held { return "The TV may still be on. Connect to use the remote." }
        if identity.host.isEmpty { return "Add your TV to get started." }
        if session.reach == .off || canWake {
            return canWake
                ? "This device is still paired. Turn the TV on to reconnect."
                : "Turn the TV on with its remote, then connect. Or set up wake so this device can turn it on."
        }
        return "Connect when the TV is on."
    }
    public var statusText: String {
        if session.pairing { return "Accept the connection on your TV" }
        if session.connecting { return "Connecting…" }
        if session.reach == .waking { return "Waiting for your TV" }
        if session.connected { return "Connected" }
        if session.error != nil { return "Couldn't connect" }
        if identity.host.isEmpty { return "No TV yet" }
        if session.reach == .held { return "Ready to reconnect" }
        if session.reach == .off || canWake { return "TV is off" }
        return "Ready when the TV is on"
    }

    public func performLinkAction() {
        switch linkAction {
        case .turnOff, .turnOn: power()
        case .connect: connect()
        case .cancel: disconnect(held: session.reach != .off && session.reach != .waking)
        case .setUpWake, .addTV: break
        }
    }
    public var orderedInputs: [TVInput] { catalog.orderedInputs(activeID: displayForegroundID) }
    public var mostUsedApps: [TVApp] { usage.mostUsed(apps: catalog.apps, host: identity.host) }

    public func connect(allowFirstUseTrust: Bool = true) { session.connect(allowFirstUseTrust: allowFirstUseTrust) }
    public func disconnect(held: Bool = false) { session.disconnect(stopReconnect: true, held: held) }

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
                self?.session.markTurnedOff()
            }
        } else if session.reach == .held {
            session.connect()
        } else if canWake, session.reach != .waking {
            beginWake()
        }
    }

    public func beginWake() {
        do {
            try TVDiscovery.wake(mac: identity.mac, host: identity.host)
        } catch {
            session.error = error.localizedDescription
            return
        }
        session.beginWaitingForWake()
        session.connect(allowFirstUseTrust: false)
    }

    public func saveWakeAddress(_ raw: String) -> Bool {
        guard let mac = HostAddress.normalizedMAC(raw) else { return false }
        identity.mac = mac
        identity.save()
        return true
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
        guard !identity.host.isEmpty, !session.connecting, !session.connected else { return }
        if session.reach == .off {
            session.connect(allowFirstUseTrust: false, retryUnreachable: false)
            return
        }
        guard session.wantsReconnect else { return }
        session.connect(allowFirstUseTrust: false)
    }
}
