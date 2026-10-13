import SwiftUI
import LGwebOSCore

public struct InputRow: View {
    private let input: TVInput
    private let active: Bool
    private let accent: Color
    private let enabled: Bool
    private let action: () -> Void
    public init(input: TVInput, active: Bool, accent: Color, enabled: Bool, action: @escaping () -> Void) {
        self.input = input
        self.active = active
        self.accent = accent
        self.enabled = enabled
        self.action = action
    }
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(isPlayStation ? Color(red: 0.02, green: 0.17, blue: 0.44) : Color.white.opacity(0.055))
                    if isPlayStation { BrandImage(name: "playstation", width: 24, height: 24) }
                    else if input.label.localizedCaseInsensitiveContains("Chromecast") { BrandImage(name: "googlecast", width: 22, height: 22) }
                    else { Image(systemName: "cable.connector").font(.system(size: 15)).foregroundStyle(RemotePalette.muted) }
                }
                .frame(width: 34, height: 34)
                VStack(alignment: .leading, spacing: 3) {
                    Text(input.label).font(.system(size: 12, weight: .semibold))
                    Text(input.id.replacingOccurrences(of: "_", with: " ") + " · " + (active ? "Active" : input.connected ? "Connected" : "No device"))
                        .font(.system(size: 10)).foregroundStyle(RemotePalette.muted)
                }
                Spacer()
                if active {
                    Text("ACTIVE").font(.system(size: 7, weight: .bold)).tracking(0.5).foregroundStyle(accent)
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 12)).foregroundStyle(accent)
                } else {
                    Image(systemName: "chevron.right").font(.system(size: 11)).foregroundStyle(RemotePalette.muted)
                }
            }
            .padding(.horizontal, 9).padding(.vertical, 7)
            .background(RoundedRectangle(cornerRadius: 10).fill(active ? accent.opacity(0.13) : Color.clear))
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(active ? accent.opacity(0.32) : Color.clear, lineWidth: 0.7))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .remoteHelp("Switch TV to \(input.label)")
        .accessibilityAddTraits(active ? .isSelected : [])
    }
    private var isPlayStation: Bool {
        input.label.localizedCaseInsensitiveContains("PS5") || input.label.localizedCaseInsensitiveContains("PlayStation")
    }
}

public struct NowPlayingCard: View {
    private let title: String
    private let tagline: String
    private let status: String
    private let inputLabel: String?
    private let accent: Color
    private let connected: Bool
    private let mark: AnyView
    public init(title: String, tagline: String, status: String, inputLabel: String?, accent: Color, connected: Bool, mark: AnyView) {
        self.title = title
        self.tagline = tagline
        self.status = status
        self.inputLabel = inputLabel
        self.accent = accent
        self.connected = connected
        self.mark = mark
    }
    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Ellipse().fill(accent.opacity(connected ? 0.28 : 0.08)).frame(width: 230, height: 110).blur(radius: 38).offset(y: 9)
                BrandImage(name: "tv-hero", width: 312, height: 178)
                VStack(spacing: 9) {
                    mark
                    Text(title).font(.system(size: 15, weight: .semibold)).tracking(-0.3).lineLimit(1)
                }
                .offset(y: -6)
                .shadow(color: accent.opacity(0.5), radius: 16)
            }
            .frame(height: 174)
            HStack(spacing: 5) {
                Circle().fill(connected ? accent : RemotePalette.muted).frame(width: 4, height: 4)
                Text(status).font(.system(size: 8, weight: .bold)).tracking(1.1).foregroundStyle(RemotePalette.muted)
                Spacer()
                if let inputLabel {
                    Text(inputLabel).font(.system(size: 9, weight: .medium)).foregroundStyle(accent)
                }
            }
            .padding(.horizontal, 10).padding(.top, 7)
            Text(tagline).font(.system(size: 11)).foregroundStyle(Color.white.opacity(0.65))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10).padding(.top, 6).padding(.bottom, 7)
        }
        .padding(.top, 2)
    }
}
