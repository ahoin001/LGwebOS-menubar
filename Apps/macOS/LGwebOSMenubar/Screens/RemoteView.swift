import AppKit
import SwiftUI
import LGwebOSCore
import LGwebOSUI

struct RemoteView: View {
    let model: RemoteCoordinator
    @ObservedObject var metrics: PanelMetrics
    @State private var tab: RemoteSection = .home
    @State private var settings = false
    @State private var pictureDraft: [String: Int] = [:]

    private var theme: BrandTheme { BrandTheme.forApp(model.displayForegroundID, title: model.currentInput?.label ?? displayedTitle) }
    private var displayedTitle: String {
        let title = model.currentAppTitle
        return title.isEmpty ? "Your TV, on your Mac." : title
    }

    var body: some View {
        VStack(spacing: 0) {
            header.padding(.top, 16).padding(.bottom, 16)
            tabs.padding(.bottom, 14)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if settings {
                        SettingsScreen(model: model) { settings = false }
                    } else {
                        if tab != .home { RemoteSectionTitle(tab.rawValue.uppercased(), busy: model.session.connecting) }
                        if !model.session.connected { connectionPanel }
                        tabContent
                    }
                    feedback
                }
                .padding(.bottom, 12)
            }
            .scrollIndicators(.hidden)
            footer.padding(.top, 10).padding(.bottom, 12)
        }
        .padding(.horizontal, 13)
        .frame(width: 360)
        .background(RemoteBackground())
        .foregroundStyle(RemotePalette.ink)
        .preferredColorScheme(.dark)
        .font(.system(size: 12))
        .tint(theme.color)
        .animation(.easeOut(duration: 0.22), value: model.displayForegroundID)
        .onChange(of: tab) { _, _ in updateHeight() }
        .onChange(of: settings) { _, _ in updateHeight() }
        .onChange(of: model.picture.values) { _, value in pictureDraft = value }
        .onChange(of: model.picture.applying) { _, value in if !value { pictureDraft = model.picture.values } }
        .onAppear {
            pictureDraft = model.picture.values
            updateHeight()
            if model.identity.host.isEmpty { settings = true }
        }
    }

    @ViewBuilder private var tabContent: some View {
        switch tab {
        case .home: HomeScreen(model: model, accent: theme.color) { tab = $0 }
        case .remote: RemoteControlScreen(model: model, accent: theme.color)
        case .apps: AppsScreen(model: model, accent: theme.color)
        case .media: CastScreen(model: model, accent: theme.color)
        case .info: PictureScreen(model: model, accent: theme.color, draft: $pictureDraft)
        case .usage: ActivityScreen(model: model, accent: theme.color)
        case .logs, .wake: EmptyView()
        }
    }

    private var header: some View {
        HStack(spacing: 9) {
            BrandImage(name: "lg", width: 31, height: 31)
            VStack(alignment: .leading, spacing: 3) {
                Text(model.identity.name).font(.system(size: 17, weight: .semibold)).tracking(-0.3)
                Text("LG · webOS").font(.system(size: 10, weight: .medium)).foregroundStyle(RemotePalette.muted)
            }
            Spacer()
            Menu {
                Button("Refresh TV data") { Task { await model.refresh() } }
                Button(model.session.connected ? "Stop controlling" : "Connect") {
                    if model.session.connected { model.disconnect(held: true) }
                    else if model.identity.host.isEmpty { settings = true }
                    else { model.connect() }
                }
                Divider()
                Button("Quit LGwebOS-menubar") { NSApplication.shared.terminate(nil) }
            } label: {
                Image(systemName: "ellipsis").frame(width: 24, height: 30).foregroundStyle(RemotePalette.muted)
            }
            .menuStyle(.borderlessButton).menuIndicator(.hidden).fixedSize()
            Menu {
                switch model.linkAction {
                case .turnOff: Button("Turn off") { model.performLinkAction() }
                case .turnOn: Button("Turn on") { model.performLinkAction() }
                case .cancel: Button("Waiting for your TV") { model.performLinkAction() }
                case .connect: Button("Connect") { model.performLinkAction() }
                case .setUpWake: Button("Set up turning the TV on") { settings = true }
                case .addTV: Button("Add a TV") { settings = true }
                }
            } label: {
                Image(systemName: "power").font(.system(size: 17))
                    .foregroundStyle(model.linkAction == .turnOff || model.linkAction == .turnOn ? Color.white : RemotePalette.muted)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color.white.opacity(0.06)))
            }
            .menuStyle(.borderlessButton).menuIndicator(.hidden).fixedSize().help(model.statusText)
        }
    }

    private var tabs: some View {
        HStack(spacing: 4) {
            ForEach(RemoteSection.allCases.filter { $0 != .logs && $0 != .wake }) { item in
                Button { tab = item; settings = false } label: {
                    Image(systemName: item.symbol).font(.system(size: 16, weight: .medium))
                        .foregroundStyle(tab == item && !settings ? theme.color : RemotePalette.muted)
                        .frame(maxWidth: .infinity).frame(height: 35)
                        .background(RoundedRectangle(cornerRadius: 9).fill(tab == item && !settings ? theme.color.opacity(0.2) : .clear))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain).help(item.rawValue).accessibilityLabel(item.rawValue)
            }
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.066)))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.white.opacity(0.08), lineWidth: 0.7))
    }

    private var connectionPanel: some View {
        RemoteCard {
            VStack(alignment: .leading, spacing: 10) {
                Label(model.statusText, systemImage: model.linkSymbol).fontWeight(.semibold)
                Text(model.connectionDetail)
                    .font(.system(size: 11)).foregroundStyle(RemotePalette.muted)
                Button(model.linkActionTitle) {
                    switch model.linkAction {
                    case .setUpWake, .addTV: settings = true
                    default: model.performLinkAction()
                    }
                }
            }
        }
    }

    @ViewBuilder private var feedback: some View {
        if let error = model.session.error {
            RemoteCard {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.circle").foregroundStyle(.orange)
                    Text(error).font(.system(size: 11)).fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                    Button { model.session.error = nil } label: { Image(systemName: "xmark").font(.system(size: 10)) }
                        .buttonStyle(.plain).help("Dismiss message")
                }
            }
        } else if let notice = model.session.notice {
            Text(notice).font(.system(size: 11)).foregroundStyle(RemotePalette.muted).fixedSize(horizontal: false, vertical: true)
        }
    }

    private var footer: some View {
        HStack(spacing: 6) {
            Circle().fill(model.session.connected ? .green : model.session.connecting ? .orange : RemotePalette.muted).frame(width: 5, height: 5)
            Text(model.statusText).font(.system(size: 10)).foregroundStyle(RemotePalette.muted)
            Spacer()
            Text(model.identity.model).font(.system(size: 8, weight: .semibold)).tracking(1).foregroundStyle(Color.white.opacity(0.27))
            Button { settings.toggle() } label: {
                Image(systemName: settings ? "xmark" : "slider.horizontal.3")
                    .font(.system(size: 12)).foregroundStyle(RemotePalette.muted).frame(width: 24, height: 22)
            }
            .buttonStyle(.plain).help("App settings")
        }
    }

    private func updateHeight() {
        if settings { metrics.preferredHeight = 650 }
        else { metrics.preferredHeight = tab == .home || tab == .remote ? 740 : tab == .media ? 590 : tab == .usage ? 580 : 660 }
    }
}
