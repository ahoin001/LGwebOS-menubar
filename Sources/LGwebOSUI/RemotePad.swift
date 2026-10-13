import SwiftUI

public struct RemoteMetrics: Equatable {
    public var pad: CGFloat
    public var direction: CGFloat
    public var side: CGFloat
    public var sideHeight: CGFloat
    public var mediaHeight: CGFloat
    public var pointerHeight: CGFloat
    public init(pad: CGFloat, direction: CGFloat, side: CGFloat, sideHeight: CGFloat, mediaHeight: CGFloat, pointerHeight: CGFloat) {
        self.pad = pad
        self.direction = direction
        self.side = side
        self.sideHeight = sideHeight
        self.mediaHeight = mediaHeight
        self.pointerHeight = pointerHeight
    }
    public static let compact = RemoteMetrics(pad: 138, direction: 29, side: 43, sideHeight: 42, mediaHeight: 30, pointerHeight: 85)
    public static let touch = RemoteMetrics(pad: 220, direction: 44, side: 56, sideHeight: 52, mediaHeight: 44, pointerHeight: 160)
}

public struct DirectionalPad: View {
    private let accent: Color
    private let metrics: RemoteMetrics
    private let homeDisabled: Bool
    private let onPress: (String) -> Void
    private let onClick: () -> Void
    public init(accent: Color, metrics: RemoteMetrics = .compact, homeDisabled: Bool = false, onPress: @escaping (String) -> Void, onClick: @escaping () -> Void) {
        self.accent = accent
        self.metrics = metrics
        self.homeDisabled = homeDisabled
        self.onPress = onPress
        self.onClick = onClick
    }
    public var body: some View {
        HStack(spacing: 15) {
            VStack(spacing: 12) {
                side("house", "Close app and open Home", "HOME").disabled(homeDisabled)
                side("arrow.uturn.backward", "Back", "BACK")
            }
            ZStack {
                Circle().fill(Color.white.opacity(0.055)).overlay(Circle().strokeBorder(Color.white.opacity(0.07)))
                VStack { direction("chevron.up", "UP"); Spacer(); direction("chevron.down", "DOWN") }.padding(6)
                HStack { direction("chevron.left", "LEFT"); Spacer(); direction("chevron.right", "RIGHT") }.padding(6)
                Button(action: onClick) {
                    Text("OK").font(.system(size: 12, weight: .semibold)).frame(width: metrics.direction + 17, height: metrics.direction + 17)
                        .background(Circle().fill(accent.opacity(0.2))).foregroundStyle(accent)
                }
                .buttonStyle(.plain).remoteHelp("Confirm")
            }
            .frame(width: metrics.pad, height: metrics.pad)
            VStack(spacing: 12) {
                side("gearshape", "TV settings", "MENU")
                side("xmark", "Exit screen", "EXIT")
            }
        }
        .frame(maxWidth: .infinity)
    }
    private func direction(_ symbol: String, _ command: String) -> some View {
        Button { onPress(command) } label: {
            Image(systemName: symbol).font(.system(size: 13, weight: .semibold))
                .frame(width: metrics.direction, height: metrics.direction).contentShape(Rectangle())
        }
        .buttonStyle(.plain).remoteHelp(command)
    }
    private func side(_ symbol: String, _ title: String, _ command: String) -> some View {
        Button { onPress(command) } label: {
            Image(systemName: symbol).font(.system(size: 15)).frame(width: metrics.side, height: metrics.sideHeight)
        }
        .buttonStyle(RemoteButtonStyle(accent: accent)).remoteHelp(title).accessibilityLabel(title)
    }
}

public struct MediaTransportBar: View {
    private let accent: Color
    private let height: CGFloat
    private let onCommand: (String) -> Void
    public init(accent: Color, height: CGFloat = 30, onCommand: @escaping (String) -> Void) {
        self.accent = accent
        self.height = height
        self.onCommand = onCommand
    }
    public var body: some View {
        HStack(spacing: 7) {
            button("backward.end.fill", "Rewind", "rewind")
            button("play.fill", "Play", "play")
            button("pause.fill", "Pause", "pause")
            button("stop.fill", "Stop", "stop")
            button("forward.end.fill", "Fast forward", "fastForward")
        }
    }
    private func button(_ symbol: String, _ title: String, _ command: String) -> some View {
        Button { onCommand(command) } label: {
            Image(systemName: symbol).font(.system(size: 11)).frame(maxWidth: .infinity).frame(height: height)
        }
        .buttonStyle(RemoteButtonStyle(accent: accent)).remoteHelp(title).accessibilityLabel(title)
    }
}

public struct PointerPad: View {
    private let accent: Color
    private let height: CGFloat
    private let onMove: (Int, Int) -> Void
    private let onClick: () -> Void
    @State private var translation = CGSize.zero
    public init(accent: Color, height: CGFloat = 85, onMove: @escaping (Int, Int) -> Void, onClick: @escaping () -> Void) {
        self.accent = accent
        self.height = height
        self.onMove = onMove
        self.onClick = onClick
    }
    public var body: some View {
        VStack(spacing: 9) {
            HStack {
                Label("TV pointer", systemImage: "cursorarrow").fontWeight(.semibold)
                Spacer()
                Text("Drag · tap to click").font(.system(size: 9)).foregroundStyle(RemotePalette.muted)
            }
            RoundedRectangle(cornerRadius: 12).fill(accent.opacity(0.065))
                .overlay(Image(systemName: "hand.draw").font(.system(size: 25, weight: .light)).foregroundStyle(accent.opacity(0.7)))
                .frame(height: height)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 2).onChanged { value in
                    let delta = CGSize(width: value.translation.width - translation.width, height: value.translation.height - translation.height)
                    translation = value.translation
                    onMove(Int(delta.width * 1.8), Int(delta.height * 1.8))
                }.onEnded { _ in translation = .zero })
                .simultaneousGesture(TapGesture().onEnded { onClick() })
                .accessibilityLabel("TV touchpad")
        }
    }
}
