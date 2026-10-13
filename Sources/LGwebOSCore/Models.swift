import Foundation

public struct TVApp: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let icon: String?
    public init(id: String, title: String, icon: String?) {
        self.id = id
        self.title = title
        self.icon = icon
    }
}

public struct TVInput: Identifiable, Equatable, Sendable {
    public let id: String
    public let label: String
    public let connected: Bool
    public let appID: String
    public init(id: String, label: String, connected: Bool, appID: String) {
        self.id = id
        self.label = label
        self.connected = connected
        self.appID = appID
    }
}

public struct RemoteEvent: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let date: Date
    public let title: String
    public let detail: String
    public init(title: String, detail: String) {
        id = UUID()
        date = Date()
        self.title = title
        self.detail = detail
    }
}

public struct TVDevice: Identifiable, Equatable, Sendable {
    public var id: String { host }
    public let host: String
    public let name: String
    public let model: String
    public let mac: String?
    public init(host: String, name: String, model: String, mac: String?) {
        self.host = host
        self.name = name
        self.model = model
        self.mac = mac
    }
}
