import SwiftUI
import LGwebOSCore
import LGwebOSUI

struct RootView: View {
    let model: RemoteCoordinator
    let approval: CertificateApproval
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var section: RemoteSection? = .home
    @State private var settings = false

    var body: some View {
        Group {
            if sizeClass == .regular {
                NavigationSplitView {
                    List(selection: $section) {
                        ForEach(RemoteSection.allCases) { item in
                            Label(item.rawValue, systemImage: item.symbol).tag(Optional(item))
                        }
                    }
                    .navigationTitle(model.identity.name)
                } detail: {
                    NavigationStack { page(section ?? .home).navigationTitle((section ?? .home).rawValue).toolbar { toolbar } }
                }
            } else {
                TabView(selection: $section) {
                    ForEach(RemoteSection.allCases) { item in
                        NavigationStack { page(item).navigationTitle(item.rawValue).toolbar { toolbar } }
                            .tabItem { Label(item.rawValue, systemImage: item.symbol) }
                            .tag(Optional(item))
                    }
                }
            }
        }
        .sheet(isPresented: $settings) { SettingsScreen(model: model) }
        .sheet(isPresented: certificatePresented) {
            if let prompt = approval.pending { CertificateSheet(prompt: prompt, resolve: approval.resolve) }
        }
        .background(RemoteBackground().ignoresSafeArea())
        .foregroundStyle(RemotePalette.ink)
    }

    private var certificatePresented: Binding<Bool> {
        Binding(get: { approval.pending != nil }, set: { if !$0 { approval.resolve(false) } })
    }

    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button { model.power() } label: { Image(systemName: "power") }
                .disabled(!model.session.connected && model.identity.mac.isEmpty)
                .accessibilityLabel(model.session.connected ? "Turn TV off" : "Wake TV")
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button { settings = true } label: { Image(systemName: "slider.horizontal.3") }
                .accessibilityLabel("Settings")
        }
    }

    private func page(_ item: RemoteSection) -> some View {
        ScreenColumn {
            if !model.session.connected { ConnectionBanner(model: model) { settings = true } }
            switch item {
            case .home: HomeScreen(model: model)
            case .remote: RemoteScreen(model: model)
            case .apps: AppsScreen(model: model)
            case .media: CastScreen(model: model)
            case .usage: ActivityScreen(model: model)
            case .info: PictureScreen(model: model)
            }
            if let error = model.session.error {
                RemoteCard {
                    HStack(alignment: .top) {
                        Image(systemName: "exclamationmark.circle").foregroundStyle(.orange)
                        Text(error).font(.subheadline)
                        Spacer()
                        Button { model.session.error = nil } label: { Image(systemName: "xmark") }.buttonStyle(.plain)
                    }
                }
            } else if let notice = model.session.notice {
                Text(notice).font(.footnote).foregroundStyle(RemotePalette.muted)
            }
        }
    }
}

struct ScreenColumn<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) { content() }
                .padding(16)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
        }
        .background(RemoteBackground().ignoresSafeArea())
    }
}

struct ConnectionBanner: View {
    let model: RemoteCoordinator
    let openSettings: () -> Void
    var body: some View {
        RemoteCard {
            VStack(alignment: .leading, spacing: 10) {
                Label(model.statusText, systemImage: model.session.pairing ? "checkmark.shield" : "wifi").fontWeight(.semibold)
                Text(model.session.pairing ? "Accept “LG Remote App” on your TV." : "This device and your TV must be on the same network.")
                    .font(.subheadline).foregroundStyle(RemotePalette.muted)
                Button(model.session.connecting ? "Cancel" : "Connect to TV") {
                    if model.session.connecting { model.disconnect() }
                    else if model.identity.host.isEmpty { openSettings() }
                    else { model.connect() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
