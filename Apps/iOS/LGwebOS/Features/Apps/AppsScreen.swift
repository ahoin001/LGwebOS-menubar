import SwiftUI
import LGwebOSCore
import LGwebOSUI

struct AppsScreen: View {
    let model: RemoteCoordinator
    @State private var search = ""

    var body: some View {
        let apps = model.catalog.shortcuts.filter { search.isEmpty || $0.title.localizedCaseInsensitiveContains(search) }
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(RemotePalette.muted)
                TextField("Search \(model.catalog.apps.count) apps", text: $search)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.06)))
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(apps) { app in
                    let color = BrandTheme.forApp(app.id, title: app.title).color
                    VStack(spacing: 10) {
                        HStack {
                            Spacer()
                            Button { model.catalog.toggleFavorite(app) } label: {
                                Image(systemName: model.catalog.favorites.contains(app.id) ? "star.fill" : "star")
                                    .foregroundStyle(model.catalog.favorites.contains(app.id) ? color : RemotePalette.muted)
                                    .frame(width: 44, height: 32)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Favorite \(app.title)")
                        }
                        Button { model.catalog.launch(app) } label: {
                            VStack(spacing: 8) {
                                AppMark(app: app, size: 52)
                                Text(app.title).font(.caption).lineLimit(2).frame(minHeight: 32)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                        .disabled(!model.session.connected)
                        if model.displayForegroundID == app.id {
                            Text("ACTIVE").font(.caption2.weight(.bold)).foregroundStyle(color)
                        }
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 14).fill(color.opacity(0.16)))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(color.opacity(model.displayForegroundID == app.id ? 0.7 : 0.15)))
                }
            }
        }
    }
}
