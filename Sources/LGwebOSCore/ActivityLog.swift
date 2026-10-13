import Foundation
import Observation

@MainActor
@Observable
public final class ActivityLog {
    public private(set) var events: [RemoteEvent] = []
    var onFailure: ((String) -> Void)?
    private let file: URL

    public init(directory: URL) {
        file = directory.appendingPathComponent("events.json")
        events = (try? JSONDecoder().decode([RemoteEvent].self, from: Data(contentsOf: file))) ?? []
    }

    public func log(_ title: String, _ detail: String) {
        events.insert(RemoteEvent(title: title, detail: detail), at: 0)
        if events.count > 200 { events.removeLast(events.count - 200) }
        guard title != "Read" else { return }
        let persisted = events.filter { $0.title != "Read" }
        do {
            try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONEncoder().encode(persisted).write(to: file, options: .atomic)
        } catch {
            onFailure?("Could not save the local event history.")
        }
    }
}
