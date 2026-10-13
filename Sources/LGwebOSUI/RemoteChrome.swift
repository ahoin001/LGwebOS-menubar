import SwiftUI
import LGwebOSCore

public enum RemotePalette {
    public static let canvasTop = Color(red: 0.065, green: 0.070, blue: 0.080)
    public static let canvasBottom = Color(white: 0.042)
    public static let ink = Color.white.opacity(0.86)
    public static let muted = Color.white.opacity(0.49)
    public static let cardFill = Color.white.opacity(0.068)
    public static let hairline = Color.white.opacity(0.085)
}

public struct RemoteBackground: View {
    public init() {}
    public var body: some View {
        LinearGradient(colors: [RemotePalette.canvasTop, RemotePalette.canvasBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

public struct RemoteCard<Content: View>: View {
    private let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View {
        content
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(RemotePalette.cardFill))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(RemotePalette.hairline, lineWidth: 0.7))
    }
}

public struct RemoteButtonStyle: ButtonStyle {
    private let accent: Color
    private let selected: Bool
    public init(accent: Color, selected: Bool = false) {
        self.accent = accent
        self.selected = selected
    }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(selected ? accent : Color.white.opacity(0.79))
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(selected ? accent.opacity(0.19) : Color.white.opacity(configuration.isPressed ? 0.13 : 0.065))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

public struct RemoteSectionTitle: View {
    private let title: String
    private let busy: Bool
    public init(_ title: String, busy: Bool = false) {
        self.title = title
        self.busy = busy
    }
    public var body: some View {
        HStack {
            Text(title).font(.system(size: 11, weight: .bold)).tracking(0.8).foregroundStyle(RemotePalette.muted)
            Spacer()
            if busy {
                #if os(macOS)
                ProgressView().controlSize(.mini)
                #else
                ProgressView()
                #endif
            }
        }
    }
}

public enum RemoteDuration {
    public static func format(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        if minutes == 0 { return "\(Int(seconds)) s" }
        return minutes >= 60 ? "\(minutes / 60) h \(minutes % 60) min" : "\(minutes) min"
    }
}

extension View {
    @ViewBuilder func remoteHelp(_ text: String) -> some View {
        #if os(macOS)
        help(text)
        #else
        accessibilityHint(text)
        #endif
    }
}

public enum RemoteSection: String, CaseIterable, Identifiable {
    case home = "Your TV"
    case remote = "Remote"
    case apps = "Apps"
    case media = "Cast"
    case usage = "Activity"
    case info = "Picture"
    case logs = "Logs"
    public var id: String { rawValue }
    public var symbol: String {
        switch self {
        case .home: return "tv"
        case .remote: return "dpad"
        case .apps: return "square.grid.2x2"
        case .media: return "airplay.video"
        case .info: return "slider.horizontal.3"
        case .usage: return "chart.bar.xaxis"
        case .logs: return "list.bullet.rectangle"
        }
    }
}
