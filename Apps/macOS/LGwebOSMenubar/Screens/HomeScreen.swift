import SwiftUI
import LGwebOSCore
import LGwebOSUI

struct HomeScreen: View {
    let model: RemoteCoordinator
    let accent: Color
    let open: (RemoteSection) -> Void
    private var isPlayStation: Bool {
        model.currentInput?.label.localizedCaseInsensitiveContains("PS5") == true
            || model.currentInput?.label.localizedCaseInsensitiveContains("PlayStation") == true
    }
    private var theme: BrandTheme { BrandTheme.forApp(model.displayForegroundID, title: model.currentInput?.label ?? model.currentAppTitle) }
    private var activeTitle: String { isPlayStation ? "PlayStation 5" : model.currentInput?.label ?? (model.currentAppTitle.isEmpty ? "LG webOS" : model.currentAppTitle) }

    var body: some View {
        VStack(spacing: 12) {
            NowPlayingCard(
                title: model.session.connected ? activeTitle : "LG webOS",
                tagline: theme.tagline,
                status: model.session.connected ? (model.homeRequested ? "HOME SENT FROM MAC" : "APP REPORTED BY TV") : "YOUR TV, ON YOUR MAC",
                inputLabel: model.currentInput?.id.replacingOccurrences(of: "_", with: " "),
                accent: accent,
                connected: model.session.connected,
                mark: AnyView(mark)
            )
            VolumeCard(
                level: model.volume.level,
                muted: model.volume.muted,
                enabled: model.session.connected && model.volume.hasVolume,
                accent: accent,
                onChange: { model.volume.change($0) },
                onStep: { model.volume.step(up: $0) },
                onToggleMute: { model.volume.toggleMute() }
            )
            if !model.catalog.pinned.isEmpty {
                RemoteCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Label("Favorites", systemImage: "star").font(.system(size: 12, weight: .semibold))
                            Spacer()
                            Button { open(.apps) } label: { Text("See all").font(.system(size: 10)).foregroundStyle(RemotePalette.muted) }.buttonStyle(.plain)
                        }
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 13) {
                            ForEach(model.catalog.pinned) { app in
                                Button { model.catalog.launch(app) } label: {
                                    VStack(spacing: 8) {
                                        AppMark(app: app, size: 34)
                                        Text(app.title).font(.system(size: 9, weight: .medium)).foregroundStyle(Color.white.opacity(0.7)).lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 4).contentShape(Rectangle())
                                }
                                .buttonStyle(.plain).disabled(!model.session.connected).help("Open \(app.title) on TV")
                            }
                        }
                    }
                }
            }
            if !model.catalog.inputs.isEmpty {
                RemoteCard {
                    VStack(spacing: 7) {
                        HStack { Label("Inputs", systemImage: "cable.connector").font(.system(size: 12, weight: .semibold)); Spacer() }
                        ForEach(model.orderedInputs.filter(\.connected)) { input in
                            InputRow(input: input, active: model.displayForegroundID == input.appID, accent: accent, enabled: model.session.connected) {
                                model.catalog.switchInput(input)
                            }
                        }
                    }
                }
            }
            if !model.mostUsedApps.isEmpty {
                HStack(spacing: 8) {
                    Text("Most used").font(.system(size: 10)).foregroundStyle(RemotePalette.muted)
                    Spacer()
                    ForEach(Array(model.mostUsedApps.prefix(4))) { app in
                        Button { model.catalog.launch(app) } label: { AppMark(app: app, size: 25) }
                            .buttonStyle(.plain).help("Open \(app.title)").disabled(!model.session.connected)
                    }
                    Button { open(.usage) } label: { Image(systemName: "chevron.right").foregroundStyle(RemotePalette.muted) }
                        .buttonStyle(.plain).help("View activity")
                }
                .padding(.horizontal, 4)
            }
        }
    }

    @ViewBuilder private var mark: some View {
        if isPlayStation { BrandImage(name: "playstation", width: 45, height: 45) }
        else if !model.homeRequested, let app = model.catalog.apps.first(where: { $0.id == model.remote.foregroundID }) { AppMark(app: app, size: 43) }
        else if model.currentInput?.label.localizedCaseInsensitiveContains("Chromecast") == true { BrandImage(name: "googlecast", width: 37, height: 37) }
        else { BrandImage(name: "lg", width: 43, height: 43) }
    }
}
