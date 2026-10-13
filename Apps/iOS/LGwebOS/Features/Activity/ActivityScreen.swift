import SwiftUI
import LGwebOSCore
import LGwebOSUI

struct ActivityScreen: View {
    let model: RemoteCoordinator
    @State private var days = 1
    private var accent: Color { BrandTheme.forApp(model.displayForegroundID, title: model.currentAppTitle).color }
    private var totals: [UsageTotal] { model.usage.totals(host: model.identity.host, days: days) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Period", selection: $days) {
                Text("Today").tag(1)
                Text("7 days").tag(7)
                Text("30 days").tag(30)
            }
            .pickerStyle(.segmented)
            VStack(alignment: .leading, spacing: 6) {
                Text("SCREEN TIME").font(.caption2.weight(.bold)).tracking(1.2).foregroundStyle(RemotePalette.muted)
                Text(RemoteDuration.format(totals.reduce(0) { $0 + $1.seconds }))
                    .font(.system(size: 40, weight: .medium, design: .rounded)).foregroundStyle(accent)
                Text("Apps and inputs observed while this device is awake and connected.")
                    .font(.footnote).foregroundStyle(RemotePalette.muted)
            }
            .padding(18).frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 14).fill(accent.opacity(0.08)))
            UsageChart(totals: totals, accent: accent) { item in
                AnyView(icon(item))
            }
        }
    }

    @ViewBuilder private func icon(_ item: UsageTotal) -> some View {
        if let app = model.catalog.apps.first(where: { $0.id == item.id }) { AppMark(app: app, size: 28) }
        else if item.title.localizedCaseInsensitiveContains("PS5") { BrandImage(name: "playstation", width: 28, height: 28) }
        else { Image(systemName: "tv").frame(width: 28) }
    }
}
