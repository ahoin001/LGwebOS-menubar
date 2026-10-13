import Foundation
import Network
import UniformTypeIdentifiers

/// A bounded, single-file server. No directory or filename is exposed; only the paired TV may connect.
public final class MediaFileServer: @unchecked Sendable {
    private final class CompletionFlag: @unchecked Sendable { var completed = false }
    public let file: URL
    public let mime: String
    let token = "/" + UUID().uuidString + "/media"
    private let allowedHost: String
    private let queue = DispatchQueue(label: "br.local.LGRemote.media")
    private var listener: NWListener?
    private var connections: [UUID: NWConnection] = [:]
    private var waitingHeaders = Set<UUID>()

    public init(file: URL, allowedHost: String) {
        self.file = file
        self.allowedHost = allowedHost
        mime = UTType(filenameExtension: file.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
    }

    public func start() async throws -> URL {
        let address = try MediaHTTP.localAddress(for: allowedHost)
        let parameters = NWParameters.tcp
        parameters.requiredLocalEndpoint = .hostPort(host: NWEndpoint.Host(address), port: .any)
        let listener = try NWListener(using: parameters)
        self.listener = listener
        listener.newConnectionHandler = { [weak self] connection in self?.accept(connection) }
        return try await withCheckedThrowingContinuation { continuation in
            let flag = CompletionFlag()
            listener.stateUpdateHandler = { state in
                guard !flag.completed else { return }
                switch state {
                case .ready:
                    flag.completed = true
                    guard let port = listener.port, let url = URL(string: "http://\(address):\(port.rawValue)\(self.token)") else {
                        continuation.resume(throwing: RemoteError.message("Could not start the media server."))
                        return
                    }
                    continuation.resume(returning: url)
                case .failed(let error):
                    flag.completed = true
                    continuation.resume(throwing: error)
                case .cancelled:
                    flag.completed = true
                    continuation.resume(throwing: CancellationError())
                default:
                    break
                }
            }
            listener.start(queue: queue)
        }
    }

    public func stop() {
        queue.async { [self] in
            listener?.cancel()
            listener = nil
            for connection in connections.values { connection.cancel() }
            connections.removeAll()
        }
    }

    private func accept(_ connection: NWConnection) {
        guard case .hostPort(let host, _) = connection.endpoint,
              String(describing: host) == allowedHost || String(describing: host) == "127.0.0.1",
              connections.count < 8 else { connection.cancel(); return }
        let id = UUID()
        connections[id] = connection
        connection.stateUpdateHandler = { [weak self] state in
            if case .cancelled = state { self?.connections.removeValue(forKey: id) }
            if case .failed = state { self?.connections.removeValue(forKey: id) }
        }
        connection.start(queue: queue)
        queue.asyncAfter(deadline: .now() + 8) { [weak self] in
            if self?.waitingHeaders.contains(id) == true {
                connection.cancel()
                self?.waitingHeaders.remove(id)
            }
        }
        waitingHeaders.insert(id)
        readHeader(connection, id: id, buffer: Data())
    }

    private func readHeader(_ connection: NWConnection, id: UUID, buffer: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { [weak self] data, _, complete, error in
            guard let self else { connection.cancel(); return }
            var buffer = buffer
            if let data { buffer.append(data) }
            if buffer.count > 16384 || error != nil {
                connection.cancel()
                waitingHeaders.remove(id)
                return
            }
            if let text = String(data: buffer, encoding: .utf8), text.contains("\r\n\r\n") {
                waitingHeaders.remove(id)
                respond(connection, header: text)
            } else if complete {
                connection.cancel()
                waitingHeaders.remove(id)
            } else {
                readHeader(connection, id: id, buffer: buffer)
            }
        }
    }

    private func fail(_ connection: NWConnection, status: String, extra: String = "") {
        let data = Data("HTTP/1.1 \(status)\r\nContent-Length: 0\r\nConnection: close\r\n\(extra)\r\n".utf8)
        connection.send(content: data, completion: .contentProcessed { _ in connection.cancel() })
    }

    private func respond(_ connection: NWConnection, header: String) {
        let lines = header.components(separatedBy: "\r\n")
        let request = lines[0].split(separator: " ")
        guard request.count == 3, String(request[1]) == token else { fail(connection, status: "404 Not Found"); return }
        let method = String(request[0])
        guard method == "GET" || method == "HEAD" else {
            fail(connection, status: "405 Method Not Allowed", extra: "Allow: GET, HEAD\r\n")
            return
        }
        guard let handle = try? FileHandle(forReadingFrom: file), let size = try? handle.seekToEnd(), size > 0 else {
            fail(connection, status: "404 Not Found")
            return
        }
        let rangeHeader = lines.dropFirst().first { $0.lowercased().hasPrefix("range:") }.map {
            String($0.dropFirst(6)).trimmingCharacters(in: .whitespaces)
        }
        guard let range = try? MediaHTTP.range(rangeHeader, size: size) else {
            try? handle.close()
            fail(connection, status: "416 Range Not Satisfiable", extra: "Content-Range: bytes */\(size)\r\n")
            return
        }
        let count = range.end - range.start + 1
        let status = range.partial ? "206 Partial Content" : "200 OK"
        var response = "HTTP/1.1 \(status)\r\nContent-Type: \(mime)\r\nContent-Length: \(count)\r\nAccept-Ranges: bytes\r\nConnection: close\r\ntransferMode.dlna.org: Streaming\r\n"
        if range.partial { response += "Content-Range: bytes \(range.start)-\(range.end)/\(size)\r\n" }
        response += "\r\n"
        try? handle.seek(toOffset: range.start)
        connection.send(content: Data(response.utf8), completion: .contentProcessed { [weak self] error in
            if method == "HEAD" || error != nil {
                try? handle.close()
                connection.cancel()
            } else {
                self?.stream(connection, handle: handle, remaining: count)
            }
        })
    }

    private func stream(_ connection: NWConnection, handle: FileHandle, remaining: UInt64) {
        guard remaining > 0, let data = try? handle.read(upToCount: Int(min(remaining, 65536))), !data.isEmpty else {
            try? handle.close()
            connection.cancel()
            return
        }
        connection.send(content: data, completion: .contentProcessed { [weak self] error in
            if error != nil {
                try? handle.close()
                connection.cancel()
            } else {
                self?.stream(connection, handle: handle, remaining: remaining - UInt64(data.count))
            }
        })
    }
}
