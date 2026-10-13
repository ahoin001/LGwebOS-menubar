import AppKit
import SwiftUI
import Combine
import LGwebOSCore
import LGwebOSUI

@MainActor final class PanelMetrics: ObservableObject {
    @Published var preferredHeight: CGFloat = 740
}

final class RemotePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

struct PanelArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX - 11, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.midX - 3, y: rect.minY + 2), control: CGPoint(x: rect.midX - 6, y: rect.maxY - 6))
        path.addQuadCurve(to: CGPoint(x: rect.midX + 3, y: rect.minY + 2), control: CGPoint(x: rect.midX, y: rect.minY - 2))
        path.addQuadCurve(to: CGPoint(x: rect.midX + 11, y: rect.maxY), control: CGPoint(x: rect.midX + 6, y: rect.maxY - 6))
        path.closeSubpath()
        return path
    }
}

private struct PanelShell: View {
    let model: RemoteCoordinator
    @ObservedObject var metrics: PanelMetrics
    let height: CGFloat
    let arrowX: CGFloat
    var body: some View {
        VStack(spacing: 0) {
            PanelArrow().fill(Color(red: 0.085, green: 0.095, blue: 0.10))
                .frame(width: 24, height: 11).frame(width: 360, alignment: .leading).offset(x: arrowX - 12)
            RemoteView(model: model, metrics: metrics).frame(width: 360, height: height - 11)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Color.white.opacity(0.13), lineWidth: 0.7))
        }
        .frame(width: 360, height: height)
        .preferredColorScheme(.dark)
    }
}

@MainActor final class AppDelegate: NSObject, NSApplicationDelegate {
    let model = RemoteCoordinator()
    let metrics = PanelMetrics()
    var statusItem: NSStatusItem!
    let panel = RemotePanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
    private var host: NSHostingController<PanelShell>?
    var clickMonitor: Any?
    var keyMonitor: Any?
    private var sizeSubscription: AnyCancellable?
    private var observers: [NSObjectProtocol] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        model.session.onCertificateTrust = { host, fingerprint in
            await ConnectionTrustPrompt.confirm(host: host, fingerprint: fingerprint)
        }
        NSApplication.shared.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "tv", accessibilityDescription: "LGwebOS-menubar")
        statusItem.button?.image?.isTemplate = true
        statusItem.button?.target = self
        statusItem.button?.action = #selector(toggle)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .popUpMenu
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.transient, .fullScreenAuxiliary]
        panel.appearance = NSAppearance(named: .darkAqua)
        sizeSubscription = metrics.$preferredHeight.dropFirst().removeDuplicates().sink { [weak self] _ in
            DispatchQueue.main.async { if self?.panel.isVisible == true { self?.show() } }
        }
        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            DispatchQueue.main.async { self?.panel.orderOut(nil) }
        }
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53, self?.panel.isVisible == true {
                self?.panel.orderOut(nil)
                return nil
            }
            return event
        }
        observers.append(NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.model.session.pauseUsage() }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }
            if !CommandLine.arguments.contains("--background") { self.show() }
            if !self.model.identity.host.isEmpty { self.model.connect(allowFirstUseTrust: false) }
        }
    }

    @objc func toggle() { if panel.isVisible { panel.orderOut(nil) } else { show() } }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool { show(); return true }

    func show() {
        guard let button = statusItem.button, let anchorWindow = button.window else { return }
        let anchor = anchorWindow.convertToScreen(button.convert(button.bounds, to: nil))
        let screen = anchorWindow.screen ?? NSScreen.main!
        let visible = screen.visibleFrame
        let top = min(anchor.minY - 3, visible.maxY - 3)
        let height = min(metrics.preferredHeight, max(300, top - visible.minY - 12))
        let x = min(max(anchor.midX - 180, visible.minX + 8), visible.maxX - 368)
        let root = PanelShell(model: model, metrics: metrics, height: height, arrowX: min(342, max(18, anchor.midX - x)))
        if let host { host.rootView = root } else {
            let controller = NSHostingController(rootView: root)
            host = controller
            panel.contentViewController = controller
        }
        panel.setFrame(NSRect(x: x, y: top - height, width: 360, height: height), display: true)
        NSApplication.shared.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        model.disconnect()
        if let clickMonitor { NSEvent.removeMonitor(clickMonitor) }
        if let keyMonitor { NSEvent.removeMonitor(keyMonitor) }
        for observer in observers { NSWorkspace.shared.notificationCenter.removeObserver(observer) }
    }
}
