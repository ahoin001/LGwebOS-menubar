import Foundation
import Observation

@MainActor
@Observable
public final class CastSession {
    public private(set) var file: URL?
    public private(set) var busy = false
    public private(set) var casting = false
    public private(set) var status = "Choose a video, a song, or a photo."
    weak var commands: TVCommanding?
    private var server: MediaFileServer?
    private var transportURL: URL?
    private var scoped: URL?

    public init() {}

    public func use(file: URL) {
        if let scoped { scoped.stopAccessingSecurityScopedResource() }
        if file.startAccessingSecurityScopedResource() { scoped = file } else { scoped = nil }
        self.file = file
        status = "Ready to send. This will open the file on your TV."
    }

    public func play() {
        guard !busy, let commands, commands.isConnected, let file else { return }
        busy = true
        commands.clearError()
        let targetHost = commands.tvHost
        Task { [weak self] in
            guard let self else { return }
            defer { self.busy = false }
            var newServer: MediaFileServer?
            do {
                let control = try await DLNATransport.discover(host: targetHost)
                let server = MediaFileServer(file: file, allowedHost: targetHost)
                newServer = server
                let url = try await server.start()
                _ = try await DLNATransport.command(control, action: "SetAVTransportURI", parameters: [
                    ("CurrentURI", url.absoluteString),
                    ("CurrentURIMetaData", DLNATransport.metadata(url: url, title: file.lastPathComponent, mime: server.mime)),
                ])
                _ = try await DLNATransport.command(control, action: "Play", parameters: [("Speed", "1")])
                self.server?.stop()
                self.server = server
                transportURL = control
                casting = true
                status = "Sent to TV · \(file.lastPathComponent)"
                commands.log("Send media", file.lastPathComponent)
            } catch {
                newServer?.stop()
                commands.reportError(error.localizedDescription)
                status = "Could not play this file."
            }
        }
    }

    public func control(_ action: String) {
        guard casting, !busy, let control = transportURL, ["Play", "Pause", "Stop"].contains(action) else { return }
        busy = true
        Task { [weak self] in
            guard let self else { return }
            defer { self.busy = false }
            do {
                _ = try await DLNATransport.command(control, action: action, parameters: action == "Play" ? [("Speed", "1")] : [])
                if action == "Stop" {
                    stopPlayback()
                    status = "Casting stopped."
                } else {
                    status = action == "Pause" ? "Media paused on TV." : "Playing on TV."
                }
            } catch {
                commands?.reportError(error.localizedDescription)
            }
        }
    }

    func stopPlayback() {
        server?.stop()
        server = nil
        casting = false
        transportURL = nil
    }
}
