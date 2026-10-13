import SwiftUI
import LGwebOSCore

public struct PictureEditor: View {
    private let values: [String: Int]
    private let draft: Binding<[String: Int]>
    private let applying: Bool
    private let enabled: Bool
    private let accent: Color
    private let onApply: ([String: Int]) -> Void
    private let rows = [
        ("backlight", "Backlight", "sun.max"),
        ("brightness", "Brightness", "light.max"),
        ("contrast", "Contrast", "circle.lefthalf.filled"),
        ("color", "Color", "paintpalette"),
    ]
    public init(values: [String: Int], draft: Binding<[String: Int]>, applying: Bool, enabled: Bool, accent: Color, onApply: @escaping ([String: Int]) -> Void) {
        self.values = values
        self.draft = draft
        self.applying = applying
        self.enabled = enabled
        self.accent = accent
        self.onApply = onApply
    }
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14).fill(accent.opacity(0.08))
                VStack(spacing: 8) {
                    Image(systemName: "sun.max").font(.system(size: 29, weight: .light)).foregroundStyle(accent)
                    Text("Your picture, your way").font(.system(size: 17, weight: .semibold)).tracking(-0.3)
                    Text("Adjust the values and apply when ready.").font(.system(size: 10)).foregroundStyle(RemotePalette.muted)
                }
                .padding(.vertical, 20)
            }
            RemoteCard {
                VStack(spacing: 19) {
                    ForEach(rows, id: \.0) { key, title, symbol in
                        if values[key] != nil {
                            VStack(spacing: 9) {
                                HStack {
                                    Label(title, systemImage: symbol).foregroundStyle(Color.white.opacity(0.8))
                                    Spacer()
                                    Text("\(draft.wrappedValue[key] ?? values[key] ?? 0)").monospacedDigit().foregroundStyle(accent)
                                }
                                Slider(
                                    value: Binding(get: { Double(draft.wrappedValue[key] ?? values[key] ?? 0) }, set: { draft.wrappedValue[key] = Int($0) }),
                                    in: 0...100,
                                    step: 1
                                )
                                .accessibilityLabel(title)
                            }
                        }
                    }
                    if values.isEmpty { Text("Connect to your TV to read its settings.").foregroundStyle(RemotePalette.muted) }
                    HStack {
                        Button("Reset values") { draft.wrappedValue = values }.buttonStyle(.plain).foregroundStyle(RemotePalette.muted)
                        Spacer()
                        Button(applying ? "Applying…" : "Apply to TV") { onApply(draft.wrappedValue) }
                            .disabled(!enabled || values.isEmpty || draft.wrappedValue == values || applying)
                    }
                    .font(.system(size: 10))
                }
            }
            Text("Available settings depend on TV permissions. Values are read again after applying.").font(.system(size: 10)).foregroundStyle(RemotePalette.muted)
        }
    }
}

public struct UsageChart: View {
    private let totals: [UsageTotal]
    private let accent: Color
    private let icon: (UsageTotal) -> AnyView
    public init(totals: [UsageTotal], accent: Color, icon: @escaping (UsageTotal) -> AnyView) {
        self.totals = totals
        self.accent = accent
        self.icon = icon
    }
    public var body: some View {
        let total = totals.reduce(0) { $0 + $1.seconds }
        RemoteCard {
            VStack(spacing: 17) {
                ForEach(totals) { item in
                    let color = BrandTheme.forApp(item.id, title: item.title).color
                    VStack(spacing: 8) {
                        HStack(spacing: 9) {
                            icon(item)
                            Text(item.title).font(.system(size: 11, weight: .medium)).lineLimit(1)
                            Spacer()
                            Text(RemoteDuration.format(item.seconds)).font(.system(size: 10)).foregroundStyle(RemotePalette.muted).monospacedDigit()
                        }
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.04))
                                Capsule().fill(color).frame(width: geometry.size.width * CGFloat(item.seconds / max(total, 1)))
                            }
                        }
                        .frame(height: 4)
                    }
                }
                if totals.isEmpty {
                    VStack(spacing: 9) {
                        Image(systemName: "chart.bar.xaxis").font(.system(size: 26)).foregroundStyle(accent)
                        Text("Your history starts here").fontWeight(.medium)
                        Text("The first record appears after another TV reading.").font(.system(size: 10)).foregroundStyle(RemotePalette.muted)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 25)
                }
            }
        }
    }
}
