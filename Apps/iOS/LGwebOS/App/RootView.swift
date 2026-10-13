import SwiftUI
import LGwebOSCore
import LGwebOSUI

struct RootView: View {
    let model: RemoteCoordinator
    let approval: CertificateApproval
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var section: RemoteSection? = .home
    @State private var settings = false
    @State private var setup = false

    var body: some View {
        Group {
            if sizeClass == .regular {
                NavigationSplitView {
                    List(selection: $section) {
                        ForEach(sections) { item in
                            Label(item.rawValue, systemImage: item.symbol).tag(Optional(item))
                        }
                    }
                    .navigationTitle(model.identity.name)
                } detail: {
                    NavigationStack { page(section ?? .home).navigationTitle((section ?? .home).rawValue).toolbar { toolbar } }
                }
            } else {
                TabView(selection: $section) {
                    ForEach(sections) { item in
                        NavigationStack { page(item).navigationTitle(item.rawValue).toolbar { toolbar } }
                            .tabItem { Label(item.rawValue, systemImage: item.symbol) }
                            .tag(Optional(item))
                    }
                }
            }
        }
        .sheet(isPresented: $settings) { SettingsScreen(model: model) }
        .sheet(isPresented: $setup) { SetupWizard(model: model, allowsDismiss: !model.identity.host.isEmpty) }
        .onAppear { if model.identity.host.isEmpty { setup = true } }
        .onChange(of: model.canWake) { _, ready in
            if ready, section == .wake { section = .home }
        }
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
            Button {
                switch model.linkAction {
                case .setUpWake: section = .wake
                case .addTV: setup = true
                default: model.performLinkAction()
                }
            } label: {
                Text(model.powerTitle)
            }
            .disabled(model.session.reach == .waking)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button { settings = true } label: { Image(systemName: "slider.horizontal.3") }
                .accessibilityLabel("Settings")
        }
    }

    @ViewBuilder private func page(_ item: RemoteSection) -> some View {
        if item == .logs {
            LogsScreen(model: model)
        } else {
            screen(item)
        }
    }

    private func screen(_ item: RemoteSection) -> some View {
        ScreenColumn {
            if !model.session.connected, item != .wake {
                ConnectionBanner(model: model, setupWake: { section = .wake }) {
                    if model.identity.host.isEmpty { setup = true } else { settings = true }
                }
            }
            switch item {
            case .home: HomeScreen(model: model)
            case .remote: RemoteScreen(model: model)
            case .apps: AppsScreen(model: model)
            case .media: CastScreen(model: model)
            case .usage: ActivityScreen(model: model)
            case .info: PictureScreen(model: model)
            case .logs: EmptyView()
            case .wake: WakeSetupScreen(model: model)
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
    let setupWake: () -> Void
    let openSettings: () -> Void
    var body: some View {
        RemoteCard {
            VStack(alignment: .leading, spacing: 10) {
                Label(model.statusText, systemImage: model.linkSymbol).fontWeight(.semibold)
                Text(model.connectionDetail)
                    .font(.subheadline).foregroundStyle(RemotePalette.muted)
                Button(model.linkActionTitle) {
                    switch model.linkAction {
                    case .setUpWake: setupWake()
                    case .addTV: openSettings()
                    default: model.performLinkAction()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

private extension RootView {
    var sections: [RemoteSection] {
        RemoteSection.allCases.filter { $0 != .wake || !model.canWake }
    }
}
