import Foundation
import Observation

@MainActor
@Observable
public final class VolumeController {
    public private(set) var level: Double = 0
    public private(set) var hasVolume = false
    public private(set) var muted = false
    weak var commands: TVCommanding?
    private var volumeTask: Task<Void, Never>?

    public init() {}

    func apply(_ payload: [String: Any]) {
        let reading = SSAPPayload.volume(payload)
        if let number = reading.volume {
            level = number
            hasVolume = true
        }
        if let mute = reading.muted { muted = mute }
    }

    public func change(_ value: Double) {
        level = min(100, max(0, value))
        volumeTask?.cancel()
        volumeTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 140_000_000)
            guard let self, !Task.isCancelled, let commands = self.commands, commands.isConnected, let client = commands.client else { return }
            do {
                _ = try await client.request(SSAP.Audio.setVolume, ["volume": Int(self.level)])
                await commands.refreshState()
            } catch {
                commands.reportError(error.localizedDescription)
            }
        }
    }

    public func step(up: Bool) {
        commands?.perform { [weak self] client in
            _ = try await client.request(up ? SSAP.Audio.volumeUp : SSAP.Audio.volumeDown)
            await self?.commands?.refreshState()
        }
    }

    public func toggleMute() {
        let next = !muted
        commands?.perform { [weak self] client in
            _ = try await client.request(SSAP.Audio.setMute, ["mute": next])
            await self?.commands?.refreshState()
        }
    }

    func reset() { hasVolume = false }
    func cancelPending() { volumeTask?.cancel() }
}
