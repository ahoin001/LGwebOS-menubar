import SwiftUI
import LGwebOSCore
import LGwebOSUI

@main
struct LGwebOSApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var model = RemoteCoordinator()
    @State private var approval = CertificateApproval()

    var body: some Scene {
        WindowGroup {
            RootView(model: model, approval: approval)
                .preferredColorScheme(.dark)
                .tint(BrandAccent.current(model))
                .onAppear {
                    model.session.onCertificateTrust = { host, fingerprint in
                        await approval.confirm(host: host, fingerprint: fingerprint)
                    }
                    if !model.identity.host.isEmpty { model.connect(allowFirstUseTrust: false) }
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .background { model.pauseForBackground() }
                    if phase == .active { model.resumeAfterForeground() }
                }
        }
    }
}

enum BrandAccent {
    static func current(_ model: RemoteCoordinator) -> Color {
        BrandTheme.forApp(model.displayForegroundID, title: model.currentInput?.label ?? model.currentAppTitle).color
    }
}
