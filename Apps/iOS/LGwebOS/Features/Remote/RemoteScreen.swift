import SwiftUI
import LGwebOSCore
import LGwebOSUI

struct RemoteScreen: View {
    let model: RemoteCoordinator
    @State private var text = ""
    private var accent: Color { BrandTheme.forApp(model.displayForegroundID, title: model.currentAppTitle).color }

    var body: some View {
        VStack(spacing: 16) {
            RemoteCard {
                VStack(spacing: 18) {
                    HStack {
                        Text(model.currentAppTitle.isEmpty ? "Your TV" : model.currentAppTitle).font(.headline).lineLimit(1)
                        Spacer()
                        Circle().fill(model.remote.pointerReady ? Color.green : Color.orange).frame(width: 8, height: 8)
                        Text(model.remote.pointerReady ? "Remote ready" : "Connecting remote").font(.caption).foregroundStyle(RemotePalette.muted)
                    }
                    DirectionalPad(accent: accent, metrics: .touch, homeDisabled: model.remote.navigatingHome, onPress: model.remote.press, onClick: model.remote.clickPointer)
                    MediaTransportBar(accent: accent, height: RemoteMetrics.touch.mediaHeight, onCommand: model.remote.media)
                }
                .disabled(!model.session.connected)
            }
            RemoteCard {
                PointerPad(accent: accent, height: RemoteMetrics.touch.pointerHeight, onMove: { model.remote.movePointer(dx: $0, dy: $1) }, onClick: model.remote.clickPointer)
                    .disabled(!model.session.connected)
            }
            VolumeCard(level: model.volume.level, muted: model.volume.muted, enabled: model.session.connected && model.volume.hasVolume, accent: accent, onChange: model.volume.change, onStep: { model.volume.step(up: $0) }, onToggleMute: model.volume.toggleMute)
            HStack(spacing: 8) {
                channel("CHANNELDOWN", "Channel −", "chevron.down")
                channel("CHANNELUP", "Channel +", "chevron.up")
            }
            .disabled(!model.session.connected)
            RemoteCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Keyboard", systemImage: "keyboard").font(.headline)
                    TextField("Type into the open field on your TV", text: $text).textFieldStyle(.roundedBorder).onSubmit(send)
                    HStack {
                        Button("Send", action: send).disabled(text.isEmpty)
                        Button { model.remote.enterText() } label: { Image(systemName: "return").frame(width: 44, height: 44) }
                    }
                }
                .disabled(!model.session.connected)
            }
            Text("Playback controls depend on the open app. Navigation controls the TV.")
                .font(.footnote).foregroundStyle(RemotePalette.muted)
        }
    }

    private func channel(_ command: String, _ title: String, _ symbol: String) -> some View {
        Button { model.remote.press(command) } label: {
            Label(title, systemImage: symbol).frame(maxWidth: .infinity).frame(minHeight: 44)
        }
        .buttonStyle(RemoteButtonStyle(accent: accent))
    }

    private func send() {
        model.remote.sendText(text)
        text = ""
    }
}
