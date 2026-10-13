import SwiftUI
import UniformTypeIdentifiers
import LGwebOSCore
import LGwebOSUI

struct CastScreen: View {
    let model: RemoteCoordinator
    @State private var importing = false
    private var accent: Color { BrandTheme.forApp(model.displayForegroundID, title: model.currentAppTitle).color }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            RemoteCard {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Screen mirroring", systemImage: "airplay.video").font(.headline)
                    Text("Open Control Center, choose Screen Mirroring, and select \(model.identity.name). This app does not start mirroring itself.")
                        .font(.subheadline).foregroundStyle(RemotePalette.muted)
                }
            }
            RemoteCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Send a file", systemImage: "play.tv").font(.headline)
                    if let file = model.cast.file {
                        Text(file.lastPathComponent).font(.body.weight(.medium)).lineLimit(2)
                    }
                    Text(model.cast.status).font(.footnote).foregroundStyle(RemotePalette.muted)
                    Button("Choose file") { importing = true }.disabled(model.cast.busy)
                    Button(model.cast.busy ? "Sending…" : "Play on TV") { model.cast.play() }
                        .disabled(!model.session.connected || model.cast.file == nil || model.cast.busy)
                    if model.cast.casting {
                        HStack {
                            Button { model.cast.control("Play") } label: { Image(systemName: "play.fill").frame(maxWidth: .infinity).frame(minHeight: 44) }
                                .buttonStyle(RemoteButtonStyle(accent: accent))
                            Button { model.cast.control("Pause") } label: { Image(systemName: "pause.fill").frame(maxWidth: .infinity).frame(minHeight: 44) }
                                .buttonStyle(RemoteButtonStyle(accent: accent))
                            Button { model.cast.control("Stop") } label: { Image(systemName: "stop.fill").frame(maxWidth: .infinity).frame(minHeight: 44) }
                                .buttonStyle(RemoteButtonStyle(accent: accent))
                        }
                        .disabled(model.cast.busy)
                    }
                }
            }
            Text("Try H.264 MP4, MP3, or JPEG first. Keep this app open while the file plays. iOS suspends the connection when you leave.")
                .font(.footnote).foregroundStyle(RemotePalette.muted)
        }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.movie, .audio, .image]) { result in
            if case let .success(url) = result { model.cast.use(file: url) }
        }
    }
}
