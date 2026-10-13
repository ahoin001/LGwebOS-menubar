import Foundation

public enum RegistrationManifest {
    public static func payload(advanced: Bool) throws -> [String: Any] {
        guard let path = AppResources.bundle.url(forResource: "registration", withExtension: "json"),
              var payload = try JSONSerialization.jsonObject(with: Data(contentsOf: path)) as? [String: Any] else {
            throw RemoteError.message("The pairing manifest is unavailable.")
        }
        if !advanced, var manifest = payload["manifest"] as? [String: Any] {
            manifest.removeValue(forKey: "signatures")
            manifest.removeValue(forKey: "signed")
            payload["manifest"] = manifest
        }
        return payload
    }

    public static func isBlacklistedCertificate(_ message: String) -> Bool {
        let lower = message.lowercased()
        return lower.contains("403") && lower.contains("blacklisted certificate")
    }
}
