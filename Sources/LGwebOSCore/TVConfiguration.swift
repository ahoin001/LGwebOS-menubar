import Foundation

/// Only the current device's preferences supply TV details; no TV ships preconfigured.
public struct TVConfiguration: Equatable {
    public let host: String
    public let name: String
    public let model: String
    public let mac: String
    public let advancedControls: Bool
    public init(defaults: UserDefaults = .standard) {
        host = defaults.string(forKey: "tv.host") ?? ""
        name = defaults.string(forKey: "tv.name") ?? "LG TV"
        model = defaults.string(forKey: "tv.model") ?? ""
        mac = defaults.string(forKey: "tv.mac") ?? ""
        advancedControls = defaults.bool(forKey: "tv.advancedControls")
    }
}

public enum AppSupport {
    public static func directory() -> URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("br.local.LGRemote")
    }
}
