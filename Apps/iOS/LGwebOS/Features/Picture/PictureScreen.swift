import SwiftUI
import LGwebOSCore
import LGwebOSUI

struct PictureScreen: View {
    let model: RemoteCoordinator
    @State private var draft: [String: Int] = [:]
    private var accent: Color { BrandTheme.forApp(model.displayForegroundID, title: model.currentAppTitle).color }

    var body: some View {
        Group {
            if model.identity.advancedControls {
                PictureEditor(values: model.picture.values, draft: $draft, applying: model.picture.applying, enabled: model.session.connected, accent: accent) {
                    model.picture.apply($0)
                }
            } else {
                ControlAccessNote(advanced: false)
            }
        }
        .onAppear { draft = model.picture.values }
        .onChange(of: model.picture.values) { _, value in draft = value }
        .onChange(of: model.picture.applying) { _, applying in if !applying { draft = model.picture.values } }
    }
}
