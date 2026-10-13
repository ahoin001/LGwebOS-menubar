import Foundation

@MainActor
public final class WebOSConnection {
    public let host: String
    private let session: URLSession
    private let trust: TVCertificateTrust
    private var socket: URLSessionWebSocketTask?
    private lazy var pointerChannel = PointerChannel { [weak self] in
        guard let self else { throw CancellationError() }
        let result = try await request(SSAP.Pointer.socket)
        guard let path = result["socketPath"] as? String, let url = URL(string: path), url.host == host, url.scheme == "wss", url.port == 3001 else {
            throw RemoteError.message("The TV did not provide a compatible local navigation channel.")
        }
        let task = session.webSocketTask(with: url)
        do {
            try await trust.open(task)
            try Task.checkCancellation()
            return WebSocketPointerTransport(task: task)
        } catch {
            task.cancel(with: .goingAway, reason: nil)
            throw error
        }
    }
    private var receiver: Task<Void, Never>?
    private var waiters: [String: CheckedContinuation<[String: Any], Error>] = [:]
    private var subscriptions: [String: ([String: Any]) -> Void] = [:]
    public var onPairing: (() -> Void)?
    public var onDisconnect: ((Error) -> Void)?
    public var onEvent: ((String, String) -> Void)?
    public var onPointerState: ((Bool) -> Void)?
    public var onCertificateTrust: (@MainActor (String, String) async -> Bool)?

    public init(host: String) {
        self.host = host
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        trust = TVCertificateTrust(host: host)
        session = URLSession(configuration: configuration, delegate: trust, delegateQueue: nil)
    }

    public func connect(allowFirstUseTrust: Bool = false) async throws {
        guard Self.localHost(host), let url = URL(string: "wss://\(host):3001/") else {
            throw RemoteError.message("Enter the TV's local IPv4 address.")
        }
        let pairingHost = host
        let saved = await Task.detached(priority: .userInitiated) {
            (PairingKey.read(pairingHost), TVCertificatePin.read(pairingHost))
        }.value
        let storedKey = saved.0
        let storedPin = saved.1
        let confirmation = onCertificateTrust
        onEvent?("Connecting", "Opening port 3001 at \(host). Saved pairing key: \(storedKey == nil ? "no" : "yes").")
        guard storedPin != nil || (allowFirstUseTrust && confirmation != nil) else {
            onEvent?("Certificate", "No saved certificate, and this attempt cannot approve a new one.")
            throw RemoteError.message("This TV has no trusted certificate yet. Click Connect to confirm first-time pairing.")
        }
        onEvent?("Certificate", storedPin == nil
            ? "No saved certificate for this address. Approval is required before the connection continues."
            : "Checking the TV certificate against the saved pin.")
        let approval: (@Sendable (String, String) async -> Bool)?
        if allowFirstUseTrust {
            approval = { host, fingerprint in await confirmation?(host, fingerprint) ?? false }
        } else {
            approval = nil
        }
        trust.configure(fingerprint: storedPin, approval: approval)
        try Task.checkCancellation()
        let ws = session.webSocketTask(with: url)
        socket = ws
        try await trust.open(ws)
        onEvent?("Socket open", "The TV accepted the secure connection.")
        receiver = Task { [weak self] in
            do {
                while !Task.isCancelled {
                    let frame = try await ws.receive()
                    let data: Data
                    switch frame {
                    case .string(let text): data = Data(text.utf8)
                    case .data(let raw): data = raw
                    @unknown default: continue
                    }
                    guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { continue }
                    self?.handle(object)
                }
            } catch {
                if !Task.isCancelled { self?.failed(error) }
            }
        }
        var payload = try RegistrationManifest.payload(advanced: false)
        if let key = storedKey { payload["client-key"] = key }
        onEvent?("Register", storedKey == nil
            ? "Asking the TV to pair. Accept LG Remote App on the TV."
            : "Sending the saved pairing key.")
        let answer = try await exchange(["type": "register", "id": "register", "payload": payload], timeout: 90)
        try Task.checkCancellation()
        guard storedKey != nil || !(answer["client-key"] as? String ?? "").isEmpty else {
            throw RemoteError.message("The TV did not provide a pairing key.")
        }
        if let key = answer["client-key"] as? String, key != storedKey {
            try await Task.detached(priority: .userInitiated) { try PairingKey.save(key, host: pairingHost) }.value
        }
        if storedPin == nil, let fingerprint = trust.approvedFingerprint() {
            try await Task.detached(priority: .userInitiated) { try TVCertificatePin.save(fingerprint, host: pairingHost) }.value
        }
    }

    public nonisolated static func validHost(_ host: String) -> Bool { HostAddress.isValidIPv4(host) }
    public nonisolated static func localHost(_ host: String) -> Bool { HostAddress.isLocalIPv4(host) }

    private func handle(_ object: [String: Any]) {
        guard let id = object["id"] as? String else { return }
        let payload = object["payload"] as? [String: Any] ?? [:]
        let type = object["type"] as? String ?? ""
        if id == "register", type == "response" {
            onPairing?()
            return
        }
        if type == "error" {
            let message = object["error"] as? String ?? "The TV rejected the command."
            onEvent?(id == "register" ? "Pairing rejected" : "Error", message)
            waiters.removeValue(forKey: id)?.resume(throwing: RemoteError.message(message))
            return
        }
        if type == "registered" || type == "response" {
            if payload["returnValue"] as? Bool == false {
                waiters.removeValue(forKey: id)?.resume(throwing: RemoteError.message(payload["errorText"] as? String ?? "This command is unavailable on this TV."))
            } else {
                waiters.removeValue(forKey: id)?.resume(returning: payload)
                subscriptions[id]?(payload)
            }
        }
    }

    private func failed(_ error: Error) {
        let pending = waiters
        waiters.removeAll()
        pending.values.forEach { $0.resume(throwing: error) }
        onDisconnect?(error)
    }

    public func close() {
        receiver?.cancel()
        receiver = nil
        pointerChannel.close()
        socket?.cancel(with: .goingAway, reason: nil)
        socket = nil
        subscriptions.removeAll()
        session.invalidateAndCancel()
        let pending = waiters
        waiters.removeAll()
        pending.values.forEach { $0.resume(throwing: CancellationError()) }
    }

    private func exchange(_ object: [String: Any], timeout: UInt64 = 12) async throws -> [String: Any] {
        guard let ws = socket, let id = object["id"] as? String else { throw RemoteError.message("Connect to the TV first.") }
        let data = try JSONSerialization.data(withJSONObject: object)
        let message = String(decoding: data, as: UTF8.self)
        return try await withCheckedThrowingContinuation { continuation in
            waiters[id] = continuation
            Task { [weak self] in
                do { try await ws.send(.string(message)) }
                catch { self?.waiters.removeValue(forKey: id)?.resume(throwing: error) }
            }
            Task { [weak self] in
                try? await Task.sleep(nanoseconds: timeout * 1_000_000_000)
                self?.waiters.removeValue(forKey: id)?.resume(throwing: RemoteError.message(id == "register" ? "Pairing timed out. Accept the connection on the TV and try again." : "The TV took too long to respond."))
            }
        }
    }

    public func request(_ uri: String, _ payload: [String: Any] = [:]) async throws -> [String: Any] {
        let method = uri.split(separator: "/").last.map(String.init) ?? ""
        onEvent?(method.hasPrefix("get") || method.hasPrefix("list") ? "Read" : "Command", uri)
        return try await exchange(["type": "request", "id": UUID().uuidString, "uri": "ssap://" + uri, "payload": payload])
    }

    public func subscribe(_ uri: String, callback: @escaping ([String: Any]) -> Void) async throws {
        let id = UUID().uuidString
        subscriptions[id] = callback
        do { _ = try await exchange(["type": "subscribe", "id": id, "uri": "ssap://" + uri]) }
        catch {
            subscriptions.removeValue(forKey: id)
            throw error
        }
    }

    private var inputChannel: PointerChannel {
        pointerChannel.onState = { [weak self] in self?.onPointerState?($0) }
        return pointerChannel
    }

    public func button(_ name: String) async throws { try await inputChannel.send(PointerMessage.button(name)) }
    public func move(dx: Int, dy: Int) async throws {
        try await inputChannel.send(PointerMessage.move(dx: min(80, max(-80, dx)), dy: min(80, max(-80, dy))))
    }
    public func click() async throws { try await inputChannel.send(PointerMessage.click) }
    public func checkPointer() async throws { try await inputChannel.check() }
}
