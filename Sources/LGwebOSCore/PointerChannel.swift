import Foundation

@MainActor
protocol PointerTransport: AnyObject {
    func send(_ message: String) async throws
    func receive() async throws
    func ping() async throws
    func close()
}

private final class PingResult: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<Void, Error>?
    init(_ continuation: CheckedContinuation<Void, Error>) { self.continuation = continuation }
    func finish(_ error: Error?) {
        lock.lock()
        let pending = continuation
        continuation = nil
        lock.unlock()
        if let error { pending?.resume(throwing: error) } else { pending?.resume() }
    }
}

@MainActor
final class WebSocketPointerTransport: PointerTransport {
    let task: URLSessionWebSocketTask
    init(task: URLSessionWebSocketTask) { self.task = task }
    func send(_ message: String) async throws { try await task.send(.string(message)) }
    func receive() async throws { _ = try await task.receive() }
    func ping() async throws {
        try await withCheckedThrowingContinuation { continuation in
            let result = PingResult(continuation)
            task.sendPing { error in result.finish(error) }
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                result.finish(RemoteError.message("The remote control connection did not respond."))
            }
        }
    }
    func close() { task.cancel(with: .goingAway, reason: nil) }
}

public enum PointerMessage {
    public static let click = "type:click\n\n"
    public static func button(_ name: String) -> String { "type:button\nname:\(name)\n\n" }
    public static func move(dx: Int, dy: Int) -> String { "type:move\ndx:\(dx)\ndy:\(dy)\ndown:0\n\n" }
}

/// One ordered writer, with a receive loop that observes server-side closure.
/// A failed health check may reconnect; an actual input is never blindly replayed.
@MainActor
final class PointerChannel {
    typealias Factory = @MainActor () async throws -> any PointerTransport
    private let factory: Factory
    private var wire: (any PointerTransport)?
    private var reader: Task<Void, Never>?
    private var tail: Task<Void, Error>?
    private var tailID: UUID?
    private var closed = false
    private var lastPing: TimeInterval = 0
    var onState: ((Bool) -> Void)?
    init(factory: @escaping Factory) { self.factory = factory }
    func send(_ message: String) async throws { try await enqueue(message: message) }
    func check() async throws { try await enqueue(message: nil) }

    private func enqueue(message: String?) async throws {
        guard !closed else { throw CancellationError() }
        let previous = tail
        let id = UUID()
        let operation = Task {
            _ = try? await previous?.value
            try Task.checkCancellation()
            defer { if tailID == id { tail = nil; tailID = nil } }
            let transport = try await ready(forcePing: message == nil)
            if let message {
                do { try await transport.send(message) }
                catch { invalidate(transport); throw error }
            }
        }
        tail = operation
        tailID = id
        try await operation.value
    }

    private func ready(forcePing: Bool) async throws -> any PointerTransport {
        guard !closed else { throw CancellationError() }
        if let wire {
            if !forcePing && ProcessInfo.processInfo.systemUptime - lastPing < 10 { return wire }
            do {
                try await wire.ping()
                lastPing = ProcessInfo.processInfo.systemUptime
                return wire
            } catch {
                invalidate(wire)
                try Task.checkCancellation()
            }
        }
        let transport = try await factory()
        guard !closed, !Task.isCancelled else { transport.close(); throw CancellationError() }
        wire = transport
        reader = Task { [weak self] in
            do { while !Task.isCancelled { try await transport.receive() } }
            catch { if !Task.isCancelled { self?.invalidate(transport) } }
        }
        do {
            try await transport.ping()
            guard wire === transport else { throw RemoteError.message("The TV closed the remote control connection.") }
            lastPing = ProcessInfo.processInfo.systemUptime
            onState?(true)
            return transport
        } catch {
            invalidate(transport)
            throw error
        }
    }

    private func invalidate(_ transport: any PointerTransport) {
        guard wire === transport else { return }
        wire = nil
        reader?.cancel()
        reader = nil
        transport.close()
        lastPing = 0
        onState?(false)
    }

    func close() {
        closed = true
        tail?.cancel()
        tail = nil
        tailID = nil
        if let wire { invalidate(wire) }
    }
}

public struct PointerMotion {
    private(set) var dx = 0
    private(set) var dy = 0
    public var isEmpty: Bool { dx == 0 && dy == 0 }
    public init() {}
    public mutating func add(dx: Int, dy: Int) {
        self.dx = min(4096, max(-4096, self.dx + dx))
        self.dy = min(4096, max(-4096, self.dy + dy))
    }
    public mutating func next() -> (dx: Int, dy: Int) {
        let x = min(80, max(-80, dx))
        let y = min(80, max(-80, dy))
        dx -= x
        dy -= y
        return (x, y)
    }
}
