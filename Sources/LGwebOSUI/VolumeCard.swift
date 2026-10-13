import SwiftUI

public struct VolumeCard: View {
    private let level: Double
    private let muted: Bool
    private let enabled: Bool
    private let accent: Color
    private let onChange: (Double) -> Void
    private let onStep: (Bool) -> Void
    private let onToggleMute: () -> Void

    public init(
        level: Double,
        muted: Bool,
        enabled: Bool,
        accent: Color,
        onChange: @escaping (Double) -> Void,
        onStep: @escaping (Bool) -> Void,
        onToggleMute: @escaping () -> Void
    ) {
        self.level = level
        self.muted = muted
        self.enabled = enabled
        self.accent = accent
        self.onChange = onChange
        self.onStep = onStep
        self.onToggleMute = onToggleMute
    }

    public var body: some View {
        RemoteCard {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "speaker.wave.2.fill").foregroundStyle(RemotePalette.muted)
                    Text("TV audio").fontWeight(.semibold)
                    Spacer()
                    Text(enabled ? "\(Int(level))" : "—")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
                HStack(spacing: 9) {
                    Button(action: onToggleMute) {
                        Image(systemName: muted ? "speaker.slash.fill" : "speaker.fill")
                            .foregroundStyle(muted ? accent : RemotePalette.muted)
                            .frame(width: 20)
                    }
                    .buttonStyle(.plain)
                    .remoteHelp(muted ? "Unmute" : "Mute")
                    Slider(value: Binding(get: { level }, set: onChange), in: 0...100).tint(accent).accessibilityLabel("TV volume")
                    Image(systemName: "speaker.wave.3.fill").font(.system(size: 11)).foregroundStyle(RemotePalette.muted)
                }
                .disabled(!enabled)
                HStack {
                    Text(muted ? "Muted" : "TV speakers").font(.system(size: 10)).foregroundStyle(RemotePalette.muted)
                    Spacer()
                    Button { onStep(false) } label: { Image(systemName: "minus").frame(width: 25, height: 22) }
                        .buttonStyle(RemoteButtonStyle(accent: accent)).remoteHelp("Lower volume")
                    Button { onStep(true) } label: { Image(systemName: "plus").frame(width: 25, height: 22) }
                        .buttonStyle(RemoteButtonStyle(accent: accent)).remoteHelp("Raise volume")
                }
                .disabled(!enabled)
            }
        }
    }
}
