import SwiftUI
import LGwebOSCore
import LGwebOSUI

struct RemoteControlScreen: View {
    let model: RemoteCoordinator
    let accent: Color
    @State private var text = ""

    var body: some View {
        VStack(spacing: 12) {
            RemoteCard {
                VStack(spacing: 16) {
                    HStack {
                        Text(model.currentAppTitle.isEmpty ? "Your TV, on your Mac." : model.currentAppTitle).lineLimit(1).fontWeight(.semibold)
                        Spacer()
                        Circle().fill(model.remote.pointerReady ? Color.green : Color.orange).frame(width: 5, height: 5)
                        Text(model.remote.pointerReady ? "Remote ready" : "Connecting remote").font(.system(size: 9)).foregroundStyle(RemotePalette.muted)
                    }
                    DirectionalPad(accent: accent, homeDisabled: model.remote.navigatingHome, onPress: { model.remote.press($0) }, onClick: { model.remote.clickPointer() })
                    MediaTransportBar(accent: accent) { model.remote.media($0) }
                }
                .disabled(!model.session.connected)
            }
            RemoteCard {
                PointerPad(accent: accent, onMove: { model.remote.movePointer(dx: $0, dy: $1) }, onClick: { model.remote.clickPointer() })
                    .disabled(!model.session.connected)
            }
            VolumeCard(
                level: model.volume.level,
                muted: model.volume.muted,
                enabled: model.session.connected && model.volume.hasVolume,
                accent: accent,
                onChange: { model.volume.change($0) },
                onStep: { model.volume.step(up: $0) },
                onToggleMute: { model.volume.toggleMute() }
            )
            HStack(spacing: 8) {
                channel("CHANNELDOWN", "Channel −", "chevron.down")
                channel("CHANNELUP", "Channel +", "chevron.up")
            }
            .disabled(!model.session.connected)
            RemoteCard {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Keyboard", systemImage: "keyboard").fontWeight(.semibold)
                    TextField("Type into the open field on your TV", text: $text).textFieldStyle(.roundedBorder).onSubmit(sendText)
                    HStack {
                        Text("Open a text field on your TV.").font(.system(size: 10)).foregroundStyle(RemotePalette.muted)
                        Spacer()
                        Button("Send", action: sendText).disabled(text.isEmpty)
                        Button { model.remote.enterText() } label: { Image(systemName: "return") }.help("Confirm text on TV")
                    }
                }
                .disabled(!model.session.connected)
            }
            RemoteCard {
                VStack(spacing: 10) {
                    ForEach(model.orderedInputs) { input in
                        InputRow(input: input, active: model.displayForegroundID == input.appID, accent: accent, enabled: model.session.connected) {
                            model.catalog.switchInput(input)
                        }
                    }
                    if model.catalog.inputs.isEmpty { Text("Inputs appear after connecting.").foregroundStyle(RemotePalette.muted).padding(.vertical, 15) }
                }
            }
            Text("Playback controls depend on the open app. Navigation controls the TV; the PS5 uses its own controller.")
                .font(.system(size: 10)).foregroundStyle(RemotePalette.muted)
            Text("Select an input to change what your TV displays.").font(.system(size: 10)).foregroundStyle(RemotePalette.muted)
        }
    }

    private func channel(_ command: String, _ title: String, _ symbol: String) -> some View {
        Button { model.remote.press(command) } label: {
            Label(title, systemImage: symbol).frame(maxWidth: .infinity).frame(height: 32)
        }
        .buttonStyle(RemoteButtonStyle(accent: accent))
    }

    private func sendText() {
        model.remote.sendText(text)
        text = ""
    }
}
