import SwiftUI
import LGwebOSCore
import LGwebOSUI

struct AppsScreen: View {
    let model: RemoteCoordinator
    let accent: Color
    @State private var search = ""

    var body: some View {
        let apps = model.catalog.shortcuts.filter { search.isEmpty || $0.title.localizedCaseInsensitiveContains(search) }
        VStack(spacing: 14) {
            HStack(spacing: 7) {
                Image(systemName: "magnifyingglass").foregroundStyle(RemotePalette.muted)
                TextField("Search \(model.catalog.apps.count) apps", text: $search).textFieldStyle(.plain)
                if !search.isEmpty {
                    Button { search = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(RemotePalette.muted) }.buttonStyle(.plain)
                }
            }
            .padding(11)
            .background(RoundedRectangle(cornerRadius: 11).fill(Color.white.opacity(0.06)))
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 9), count: 3), spacing: 9) {
                ForEach(apps) { app in
                    let color = BrandTheme.forApp(app.id, title: app.title).color
                    VStack(spacing: 8) {
                        HStack {
                            Spacer()
                            Button { model.catalog.toggleFavorite(app) } label: {
                                Image(systemName: model.catalog.favorites.contains(app.id) ? "star.fill" : "star")
                                    .font(.system(size: 9))
                                    .foregroundStyle(model.catalog.favorites.contains(app.id) ? color : RemotePalette.muted)
                            }
                            .buttonStyle(.plain).help("Favorite \(app.title)").accessibilityLabel("Favorite \(app.title)")
                        }
                        Button { model.catalog.launch(app) } label: {
                            VStack(spacing: 10) {
                                AppMark(app: app, size: 43).shadow(color: color.opacity(0.18), radius: 9)
                                Text(app.title).font(.system(size: 10, weight: .medium)).lineLimit(2).frame(height: 26)
                            }
                            .frame(maxWidth: .infinity).contentShape(Rectangle())
                        }
                        .buttonStyle(.plain).disabled(!model.session.connected).help("Open \(app.title) on TV")
                        if model.displayForegroundID == app.id {
                            Text("ACTIVE").font(.system(size: 7, weight: .bold)).tracking(0.7).foregroundStyle(color)
                        } else {
                            Color.clear.frame(height: 9)
                        }
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 13).fill(LinearGradient(colors: [color.opacity(0.17), Color.white.opacity(0.035)], startPoint: .topLeading, endPoint: .bottomTrailing)))
                    .overlay(RoundedRectangle(cornerRadius: 13).strokeBorder(color.opacity(model.displayForegroundID == app.id ? 0.6 : 0.13)))
                }
            }
            Text("Click an app to open it on TV. Use the star to add favorites.").font(.system(size: 10)).foregroundStyle(RemotePalette.muted)
        }
    }
}

struct ActivityScreen: View {
    let model: RemoteCoordinator
    let accent: Color
    @State private var days = 1
    private var totals: [UsageTotal] { model.usage.totals(host: model.identity.host, days: days) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("Period", selection: $days) {
                Text("Today").tag(1)
                Text("7 days").tag(7)
                Text("30 days").tag(30)
            }
            .pickerStyle(.segmented)
            VStack(alignment: .leading, spacing: 7) {
                Text("SCREEN TIME").font(.system(size: 8, weight: .bold)).tracking(1.2).foregroundStyle(RemotePalette.muted)
                Text(RemoteDuration.format(totals.reduce(0) { $0 + $1.seconds }))
                    .font(.system(size: 38, weight: .medium, design: .rounded)).tracking(-1).foregroundStyle(accent)
                Text("Apps and inputs observed by your Mac").font(.system(size: 10)).foregroundStyle(RemotePalette.muted)
            }
            .padding(18).frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 14).fill(accent.opacity(0.08)))
            UsageChart(totals: totals, accent: accent) { item in
                AnyView(usageIcon(item))
            }
            Text("Local history starts now. Tracks the reported app or input while your Mac is awake and connected; sleep and offline periods are excluded.")
                .font(.system(size: 10)).foregroundStyle(RemotePalette.muted)
        }
    }

    @ViewBuilder private func usageIcon(_ item: UsageTotal) -> some View {
        if let app = model.catalog.apps.first(where: { $0.id == item.id }) { AppMark(app: app, size: 26) }
        else if item.title.localizedCaseInsensitiveContains("PS5") { BrandImage(name: "playstation", width: 26, height: 26) }
        else { Image(systemName: "tv").foregroundStyle(BrandTheme.forApp(item.id, title: item.title).color).frame(width: 26) }
    }
}

struct PictureScreen: View {
    let model: RemoteCoordinator
    let accent: Color
    @Binding var draft: [String: Int]
    var body: some View {
        PictureEditor(values: model.picture.values, draft: $draft, applying: model.picture.applying, enabled: model.session.connected, accent: accent) {
            model.picture.apply($0)
        }
    }
}
