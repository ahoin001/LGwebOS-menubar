import SwiftUI
import LGwebOSCore
import LGwebOSUI

struct HomeScreen: View {
    let model: RemoteCoordinator
    private var accent: Color { BrandTheme.forApp(model.displayForegroundID, title: model.currentInput?.label ?? model.currentAppTitle).color }
    private var isPlayStation: Bool {
        model.currentInput?.label.localizedCaseInsensitiveContains("PS5") == true
            || model.currentInput?.label.localizedCaseInsensitiveContains("PlayStation") == true
    }

    var body: some View {
        let theme = BrandTheme.forApp(model.displayForegroundID, title: model.currentInput?.label ?? model.currentAppTitle)
        VStack(spacing: 16) {
            NowPlayingCard(
                title: model.session.connected ? (isPlayStation ? "PlayStation 5" : (model.currentInput?.label ?? fallbackTitle)) : "LG webOS",
                tagline: theme.tagline,
                status: model.session.connected ? (model.homeRequested ? "HOME SENT FROM THIS DEVICE" : "APP REPORTED BY TV") : "YOUR TV, ON THIS DEVICE",
                inputLabel: model.currentInput?.id.replacingOccurrences(of: "_", with: " "),
                accent: accent,
                connected: model.session.connected,
                mark: AnyView(mark)
            )
            VolumeCard(level: model.volume.level, muted: model.volume.muted, enabled: model.session.connected && model.volume.hasVolume, accent: accent, onChange: model.volume.change, onStep: { model.volume.step(up: $0) }, onToggleMute: model.volume.toggleMute)
            if !model.catalog.pinned.isEmpty {
                RemoteCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Favorites", systemImage: "star").font(.headline)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 14) {
                            ForEach(model.catalog.pinned) { app in
                                Button { model.catalog.launch(app) } label: {
                                    VStack(spacing: 8) {
                                        AppMark(app: app, size: 44)
                                        Text(app.title).font(.caption).lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity).frame(minHeight: 44)
                                }
                                .buttonStyle(.plain).disabled(!model.session.connected)
                            }
                        }
                    }
                }
            }
            if !model.catalog.inputs.isEmpty {
                RemoteCard {
                    VStack(spacing: 8) {
                        Label("Inputs", systemImage: "cable.connector").font(.headline).frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(model.orderedInputs.filter(\.connected)) { input in
                            InputRow(input: input, active: model.displayForegroundID == input.appID, accent: accent, enabled: model.session.connected) {
                                model.catalog.switchInput(input)
                            }
                        }
                    }
                }
            }
        }
    }

    private var fallbackTitle: String { model.currentAppTitle.isEmpty ? "LG webOS" : model.currentAppTitle }

    @ViewBuilder private var mark: some View {
        if isPlayStation { BrandImage(name: "playstation", width: 48, height: 48) }
        else if !model.homeRequested, let app = model.catalog.apps.first(where: { $0.id == model.remote.foregroundID }) { AppMark(app: app, size: 48) }
        else if model.currentInput?.label.localizedCaseInsensitiveContains("Chromecast") == true { BrandImage(name: "googlecast", width: 40, height: 40) }
        else { BrandImage(name: "lg", width: 48, height: 48) }
    }
}
