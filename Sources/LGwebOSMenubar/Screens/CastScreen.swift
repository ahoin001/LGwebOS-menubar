import AppKit
import SwiftUI
import UniformTypeIdentifiers
import LGwebOSCore
import LGwebOSUI

struct CastScreen: View {
    let model: RemoteCoordinator
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            RemoteCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "airplay.video").font(.system(size: 26, weight: .light)).foregroundStyle(accent)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Your Mac, on the big screen").font(.system(size: 14, weight: .semibold))
                            Text("Screen mirroring with AirPlay").font(.system(size: 10)).foregroundStyle(RemotePalette.muted)
                        }
                    }
                    Text("In Control Center on your Mac, open Screen Mirroring and choose “\(model.identity.name)”. You can also use the TV as a second display in Displays settings.")
                        .font(.system(size: 11)).foregroundStyle(RemotePalette.muted).fixedSize(horizontal: false, vertical: true)
                    Button {
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.Displays-Settings.extension")!)
                    } label: { Label("Open Displays settings", systemImage: "arrow.up.right") }
                    .buttonStyle(.plain).foregroundStyle(accent)
                }
            }
            RemoteCard {
                VStack(alignment: .leading, spacing: 14) {
                    Label("Send a file", systemImage: "play.tv").font(.system(size: 14, weight: .semibold))
                    if let file = model.cast.file {
                        HStack(spacing: 10) {
                            Image(systemName: "doc.richtext").font(.system(size: 23)).foregroundStyle(accent)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(file.lastPathComponent).fontWeight(.medium).lineLimit(2)
                                Text(file.pathExtension.uppercased()).font(.system(size: 9)).foregroundStyle(RemotePalette.muted)
                            }
                        }
                        .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 10).fill(accent.opacity(0.08)))
                    }
                    Text(model.cast.status).font(.system(size: 10)).foregroundStyle(RemotePalette.muted).fixedSize(horizontal: false, vertical: true)
                    HStack {
                        Button("Choose file", action: choose).disabled(model.cast.busy)
                        Spacer()
                        Button(model.cast.busy ? "Sending…" : "Play on TV") { model.cast.play() }
                            .disabled(!model.session.connected || model.cast.file == nil || model.cast.busy)
                    }
                    .font(.system(size: 10))
                    if model.cast.casting {
                        HStack(spacing: 8) {
                            ForEach([("play.fill", "Play", "Play"), ("pause.fill", "Pause", "Pause"), ("stop.fill", "Stop", "Stop casting")], id: \.1) { symbol, action, title in
                                Button { model.cast.control(action) } label: {
                                    Image(systemName: symbol).frame(maxWidth: .infinity).frame(height: 32)
                                }
                                .buttonStyle(RemoteButtonStyle(accent: accent)).help(title).accessibilityLabel(title)
                            }
                        }
                        .disabled(model.cast.busy)
                    }
                }
            }
            Text("The file opens on TV when you click Play. Compatibility depends on the format and codec; try H.264 MP4, MP3, or JPEG first. Keep your Mac awake while casting.")
                .font(.system(size: 10)).foregroundStyle(RemotePalette.muted)
        }
    }

    private func choose() {
        let picker = NSOpenPanel()
        picker.canChooseDirectories = false
        picker.allowsMultipleSelection = false
        picker.allowedContentTypes = [.movie, .audio, .image]
        picker.prompt = "Select"
        picker.title = "Send media to your LG TV"
        if picker.runModal() == .OK, let url = picker.url { model.cast.use(file: url) }
    }
}
