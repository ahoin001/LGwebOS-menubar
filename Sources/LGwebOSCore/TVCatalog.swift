import Foundation
import Observation

@MainActor
@Observable
public final class TVCatalog {
    public private(set) var apps: [TVApp] = []
    public private(set) var inputs: [TVInput] = []
    public private(set) var favorites: Set<String>
    weak var commands: TVCommanding?
    weak var remote: RemoteController?
    private let defaults: UserDefaults
    private let knownApps: [TVApp]
    private static let preferred = ["netflix", "youtube", "amazon", "disney", "globoplay", "spotify", "hbo", "apple"]
    private static let defaultFavorites = ["netflix", "youtube.leanback.v4", "amazon", "com.disney.disneyplus-prod"]

    public init(defaults: UserDefaults = .standard, knownApps: [TVApp] = AppResources.catalog()) {
        self.defaults = defaults
        self.knownApps = knownApps
        favorites = Set(defaults.stringArray(forKey: "tv.favorites") ?? Self.defaultFavorites)
    }

    public var shortcuts: [TVApp] {
        apps.sorted { a, b in
            if favorites.contains(a.id) != favorites.contains(b.id) { return favorites.contains(a.id) }
            let ai = Self.preferred.firstIndex { a.id.localizedCaseInsensitiveContains($0) } ?? 100
            let bi = Self.preferred.firstIndex { b.id.localizedCaseInsensitiveContains($0) } ?? 100
            return ai != bi ? ai < bi : a.title.localizedStandardCompare(b.title) == .orderedAscending
        }
    }

    public var pinned: [TVApp] { shortcuts.filter { favorites.contains($0.id) } }

    public func orderedInputs(activeID: String) -> [TVInput] {
        inputs.enumerated().sorted { a, b in
            let aActive = a.element.appID == activeID
            let bActive = b.element.appID == activeID
            return aActive != bActive ? aActive : a.offset < b.offset
        }.map(\.element)
    }

    public func toggleFavorite(_ app: TVApp) {
        if favorites.contains(app.id) { favorites.remove(app.id) } else { favorites.insert(app.id) }
        defaults.set(Array(favorites), forKey: "tv.favorites")
    }

    public func launch(_ app: TVApp) {
        commands?.log("Launch app", app.title)
        commands?.perform { [weak self] client in
            _ = try await client.request(SSAP.Launcher.launch, ["id": app.id])
            self?.remote?.dismissHome()
            try? await Task.sleep(nanoseconds: 600_000_000)
            await self?.commands?.refreshState()
        }
    }

    public func switchInput(_ input: TVInput) {
        commands?.log("Switch input", input.label)
        commands?.perform { [weak self] client in
            _ = try await client.request(SSAP.Inputs.switchInput, ["inputId": input.id])
            self?.remote?.dismissHome()
            try? await Task.sleep(nanoseconds: 500_000_000)
            await self?.commands?.refreshState()
        }
    }

    func reload(_ client: WebOSConnection) async {
        do {
            let result = try await client.request(SSAP.Launcher.listLaunchPoints)
            var seen = Set<String>()
            apps = SSAPPayload.launchPoints(result).compactMap { point in
                guard seen.insert(point.id).inserted else { return nil }
                let known = knownApps.first { $0.id == point.id }
                return TVApp(id: point.id, title: known?.title ?? point.title, icon: known?.icon)
            }
        } catch {
            commands?.reportError("Could not list apps: \(error.localizedDescription)")
        }
        if let result = try? await client.request(SSAP.Inputs.list) {
            inputs = SSAPPayload.externalInputs(result)
        }
    }

    func clearLiveData() {
        apps = []
        inputs = []
    }
}
