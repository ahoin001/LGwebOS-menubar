import Foundation

public enum SSAP {
    public enum Audio {
        public static let getVolume = "audio/getVolume"
        public static let setVolume = "audio/setVolume"
        public static let volumeUp = "audio/volumeUp"
        public static let volumeDown = "audio/volumeDown"
        public static let setMute = "audio/setMute"
    }
    public enum Launcher {
        public static let listLaunchPoints = "com.webos.applicationManager/listLaunchPoints"
        public static let foreground = "com.webos.applicationManager/getForegroundAppInfo"
        public static let close = "system.launcher/close"
        public static let launch = "system.launcher/launch"
        public static let appState = "system.launcher/getAppState"
    }
    public enum Inputs {
        public static let list = "tv/getExternalInputList"
        public static let switchInput = "tv/switchInput"
    }
    public enum Power {
        public static let state = "com.webos.service.tvpower/power/getPowerState"
        public static let turnOff = "system/turnOff"
    }
    public enum System {
        public static let info = "system/getSystemInfo"
        public static let software = "com.webos.service.update/getCurrentSWInformation"
        public static let listApps = "com.webos.applicationManager/listApps"
    }
    public enum Picture {
        public static let get = "settings/getSystemSettings"
        public static let set = "settings/setSystemSettings"
        public static let keys = ["contrast", "backlight", "brightness", "color"]
        public static let allowed = Set(keys)
    }
    public enum IME {
        public static let insertText = "com.webos.service.ime/insertText"
        public static let sendEnter = "com.webos.service.ime/sendEnterKey"
    }
    public enum MediaControls {
        public static func uri(_ command: String) -> String { "media.controls/" + command }
    }
    public enum Pointer {
        public static let socket = "com.webos.service.networkinput/getPointerInputSocket"
    }
}

public enum SSAPPayload {
    public struct VolumeReading: Equatable {
        public var volume: Double?
        public var muted: Bool?
        public init(volume: Double?, muted: Bool?) {
            self.volume = volume
            self.muted = muted
        }
    }

    public struct LaunchPoint: Equatable {
        public var id: String
        public var title: String
        public init(id: String, title: String) {
            self.id = id
            self.title = title
        }
    }

    public static func volume(_ payload: [String: Any]) -> VolumeReading {
        let status = payload["volumeStatus"] as? [String: Any] ?? payload
        let raw = status["volume"]
        let level = (raw as? Double) ?? (raw as? Int).map(Double.init) ?? (raw as? NSNumber)?.doubleValue
        let muted = status["muteStatus"] as? Bool ?? status["mute"] as? Bool ?? status["muted"] as? Bool
        return VolumeReading(volume: level, muted: muted)
    }

    public static func launchPoints(_ payload: [String: Any]) -> [LaunchPoint] {
        (payload["launchPoints"] as? [[String: Any]] ?? []).compactMap { item in
            guard let id = item["id"] as? String, let title = item["title"] as? String else { return nil }
            return LaunchPoint(id: id, title: title)
        }
    }

    public static func externalInputs(_ payload: [String: Any]) -> [TVInput] {
        (payload["devices"] as? [[String: Any]] ?? []).compactMap { item in
            guard let id = item["id"] as? String else { return nil }
            var label = item["label"] as? String ?? id
            if label.hasPrefix("HDMI"), let children = item["subList"] as? [[String: Any]],
               let cecName = children.compactMap({ $0["osdName"] as? String }).first, !cecName.isEmpty {
                label = cecName
            }
            return TVInput(id: id, label: label, connected: item["connected"] as? Bool ?? false, appID: item["appId"] as? String ?? "")
        }
    }

    public static func picture(_ payload: [String: Any]) -> [String: Int] {
        guard let settings = payload["settings"] as? [String: Any] else { return [:] }
        return settings.compactMapValues { value in
            if let number = value as? Int { return number }
            if let number = value as? NSNumber { return number.intValue }
            return (value as? String).flatMap(Int.init)
        }
    }

    public static func foregroundAppID(_ payload: [String: Any]) -> String {
        payload["appId"] as? String ?? ""
    }

    public static func foregroundTitle(_ payload: [String: Any]) -> String? {
        payload["title"] as? String
    }

    public static func modelName(_ payload: [String: Any]) -> String? {
        payload["modelName"] as? String
    }

    public static func software(_ payload: [String: Any]) -> (firmware: String, product: String) {
        var firmware = payload["major_ver"] as? String ?? ""
        if let minor = payload["minor_ver"] as? String { firmware += "." + minor }
        if let micro = payload["micro_ver"] as? String { firmware += "." + micro }
        return (firmware, payload["product_name"] as? String ?? "")
    }

    public static func powerIsActive(_ payload: [String: Any]) -> Bool {
        (payload["state"] as? String)?.lowercased() == "active"
    }
}
