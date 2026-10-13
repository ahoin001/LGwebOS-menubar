import Foundation
import Observation

@MainActor
@Observable
public final class RemoteController {
    public private(set) var foregroundID = ""
    public private(set) var foregroundName = ""
    public private(set) var homeRequested = false
    public private(set) var navigatingHome = false
    public private(set) var pointerReady = false
    weak var commands: TVCommanding?
    private let catalog: TVCatalog
    private var home = HomePresentation()
    private var motion = PointerMotion()
    private var pointerMotionTask: Task<Void, Never>?

    init(catalog: TVCatalog) { self.catalog = catalog }

    public func dismissHome() {
        home.dismiss()
        homeRequested = false
    }

    public func press(_ button: String) {
        if button == "HOME" { goHome(); return }
        commands?.log("Remote", button)
        commands?.perform { [weak self] client in
            try await client.button(button)
            if ["BACK", "EXIT"].contains(button) {
                self?.dismissHome()
                await self?.commands?.refreshState()
            }
        }
    }

    public func goHome() {
        guard let commands, commands.isConnected, !navigatingHome, let client = commands.client else { return }
        navigatingHome = true
        commands.clearError()
        commands.log("Remote", "HOME · close the app and open the menu")
        let installed = Set(catalog.apps.map(\.id))
        Task { [weak self] in
            guard let self else { return }
            defer { self.navigatingHome = false }
            do {
                let foreground = try await client.request(SSAP.Launcher.foreground)
                let id = SSAPPayload.foregroundAppID(foreground)
                try await HomeNavigation.run(appID: id, installedApps: installed, closeApp: { appID in
                    self.commands?.log("Close app", self.catalog.apps.first { $0.id == appID }?.title ?? appID)
                    _ = try await client.request(SSAP.Launcher.close, ["id": appID])
                }, pressHome: {
                    try await client.button("HOME")
                    await self.commands?.refreshState()
                    self.home.didSendHome(underlyingID: self.foregroundID)
                    self.homeRequested = true
                    self.onHomeSent?()
                })
                await commands.refreshState()
            } catch {
                commands.reportError(error.localizedDescription)
                commands.log("Could not open Home", error.localizedDescription)
            }
        }
    }

    /// Pauses usage after Home is sent. Assigned by the session so usage stays out of this type's initializer.
    var onHomeSent: (() -> Void)?

    public func movePointer(dx: Int, dy: Int) {
        guard let commands, commands.isConnected, let client = commands.client, dx != 0 || dy != 0 else { return }
        motion.add(dx: dx, dy: dy)
        guard pointerMotionTask == nil else { return }
        pointerMotionTask = Task { [weak self] in
            guard let self else { return }
            defer { self.pointerMotionTask = nil }
            do {
                while !Task.isCancelled && commands.isConnected && commands.client === client && !self.motion.isEmpty {
                    let delta = self.motion.next()
                    try await client.move(dx: delta.dx, dy: delta.dy)
                    try await Task.sleep(nanoseconds: 16_000_000)
                }
            } catch {
                self.motion = PointerMotion()
                if !Task.isCancelled {
                    commands.reportError(error.localizedDescription)
                    commands.log("Pointer failed", error.localizedDescription)
                }
            }
        }
    }

    public func clickPointer() {
        commands?.log("Remote", "OK / click")
        commands?.perform { [weak self] client in
            try await client.click()
            self?.dismissHome()
            await self?.commands?.refreshState()
        }
    }

    public func media(_ command: String) {
        commands?.perform { _ = try await $0.request(SSAP.MediaControls.uri(command)) }
    }

    public func sendText(_ text: String) {
        guard !text.isEmpty else { return }
        commands?.perform { _ = try await $0.request(SSAP.IME.insertText, ["text": text, "replace": 0]) }
    }

    public func enterText() {
        commands?.perform { _ = try await $0.request(SSAP.IME.sendEnter) }
    }

    func noteForeground(
        _ payload: [String: Any],
        host: String,
        powerActive: Bool,
        connected: Bool,
        usage: UsageTracker,
        pausePower: () -> Void
    ) {
        let previous = foregroundID
        foregroundID = SSAPPayload.foregroundAppID(payload)
        home.observe(appID: foregroundID)
        homeRequested = home.requested
        if foregroundID.hasPrefix("com.webos.app.hdmi") {
            let inputID = "HDMI" + foregroundID.replacingOccurrences(of: "com.webos.app.hdmi", with: "")
            let label = catalog.inputs.first { $0.id.replacingOccurrences(of: "_", with: "") == inputID }?.label ?? inputID
            foregroundName = label == inputID ? inputID : "\(label) · \(inputID)"
        } else {
            foregroundName = SSAPPayload.foregroundTitle(payload) ?? catalog.apps.first { $0.id == foregroundID }?.title ?? "TV is on"
        }
        if previous != foregroundID { commands?.log("Reported app", foregroundName) }
        let title = currentInputLabel ?? foregroundName
        if powerActive && connected && !homeRequested {
            usage.observe(host: host, appID: foregroundID, title: title)
        } else if homeRequested {
            usage.pause()
        } else {
            pausePower()
        }
    }

    private var currentInputLabel: String? {
        homeRequested ? nil : catalog.inputs.first { $0.appID == foregroundID }?.label
    }

    func markPointer(_ ready: Bool) { pointerReady = ready }

    func clearForeground() {
        foregroundID = ""
        foregroundName = ""
    }

    func cancelPointer() {
        pointerMotionTask?.cancel()
        motion = PointerMotion()
    }
}
