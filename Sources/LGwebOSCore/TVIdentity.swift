import Foundation
import Observation

@MainActor
protocol TVCommanding: AnyObject {
    var isConnected: Bool { get }
    var client: WebOSConnection? { get }
    var tvHost: String { get }
    func perform(_ action: @escaping (WebOSConnection) async throws -> Void)
    func refreshState() async
    func reportError(_ message: String)
    func clearError()
    func reportNotice(_ message: String)
    func log(_ title: String, _ detail: String)
}

@MainActor
@Observable
public final class TVIdentity {
    public var host: String
    public var name: String
    public var model: String
    public var mac: String
    public var advancedControls: Bool
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        let stored = TVConfiguration(defaults: defaults)
        host = stored.host
        name = stored.name
        model = stored.model
        mac = stored.mac
        advancedControls = stored.advancedControls
        self.defaults = defaults
    }

    public func save() {
        defaults.set(host, forKey: "tv.host")
        defaults.set(name, forKey: "tv.name")
        defaults.set(mac, forKey: "tv.mac")
        defaults.set(model, forKey: "tv.model")
        defaults.set(advancedControls, forKey: "tv.advancedControls")
    }
}
