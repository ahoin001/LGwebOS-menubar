import Foundation
import Observation

@MainActor
@Observable
public final class UsageTracker {
    public private(set) var revision = 0
    var onFailure: ((String) -> Void)?
    private let journal: UsageJournal

    public init(directory: URL) {
        journal = UsageJournal(url: directory.appendingPathComponent("usage.json"))
    }

    public func observe(host: String, appID: String, title: String) {
        journal.observe(host: host, appID: appID, title: title)
        save()
    }

    public func pause() {
        journal.pause()
        save()
    }

    public func totals(host: String, days: Int) -> [UsageTotal] {
        let since = Calendar.current.startOfDay(for: Date()).addingTimeInterval(-Double(max(0, days - 1)) * 86400)
        return journal.totals(host: host, since: since)
    }

    public func mostUsed(apps: [TVApp], host: String, days: Int = 7) -> [TVApp] {
        totals(host: host, days: days).compactMap { total in apps.first { $0.id == total.id } }
    }

    private func save() {
        do { try journal.save() } catch { onFailure?("Could not save usage history.") }
        revision += 1
    }
}
