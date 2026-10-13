import Foundation

public enum RegistrationManifest {
    /// Permissions a current TV can grant from the on-screen Allow prompt, without the sample certificate.
    public static let grantedPermissions = [
        "READ_INSTALLED_APPS",
        "CONTROL_MOUSE_AND_KEYBOARD",
        "CONTROL_INPUT_TEXT",
        "WRITE_SETTINGS",
        "WRITE_NOTIFICATION_ALERT"
    ]

    public static func payload(advanced: Bool) throws -> [String: Any] {
        guard let path = AppResources.bundle.url(forResource: "registration", withExtension: "json"),
              var payload = try JSONSerialization.jsonObject(with: Data(contentsOf: path)) as? [String: Any] else {
            throw RemoteError.message("The pairing manifest is unavailable.")
        }
        if !advanced, var manifest = payload["manifest"] as? [String: Any] {
            manifest.removeValue(forKey: "signatures")
            manifest.removeValue(forKey: "signed")
            var permissions = manifest["permissions"] as? [String] ?? []
            for name in grantedPermissions where !permissions.contains(name) {
                permissions.append(name)
            }
            manifest["permissions"] = permissions
            payload["manifest"] = manifest
        }
        return payload
    }

    public static func isBlacklistedCertificate(_ message: String) -> Bool {
        let lower = message.lowercased()
        return lower.contains("403") && lower.contains("blacklisted certificate")
    }
}

/// A pairing key saved under an older permission list cannot gain the new list.
public enum RegistrationRepair {
    public static let generation = 2
    private static let defaultsKey = "tv.registrationGeneration"

    public static func dropPreviousPairingIfNeeded(defaults: UserDefaults, host: String) {
        guard defaults.integer(forKey: defaultsKey) < generation else { return }
        if !host.isEmpty {
            do { try PairingKey.deleteKey(host) }
            catch { return }
        }
        defaults.set(generation, forKey: defaultsKey)
    }
}
