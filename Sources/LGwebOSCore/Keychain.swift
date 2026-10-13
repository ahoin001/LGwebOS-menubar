import Foundation
import Security

public enum PairingKey {
    static func query(_ host: String) -> [String: Any] {
        [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: "br.local.LGRemote", kSecAttrAccount as String: host]
    }

    public static func read(_ host: String) -> String? {
        var q = query(host)
        q[kSecReturnData as String] = true
        q[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        guard SecItemCopyMatching(q as CFDictionary, &result) == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    public static func save(_ key: String, host: String) throws {
        let q = query(host)
        let data = Data(key.utf8)
        let status = SecItemUpdate(q as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if status == errSecItemNotFound {
            var insert = q
            insert[kSecValueData as String] = data
            insert[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            guard SecItemAdd(insert as CFDictionary, nil) == errSecSuccess else {
                throw RemoteError.message("Could not save TV pairing in Keychain.")
            }
        } else if status != errSecSuccess {
            throw RemoteError.message("Keychain refused the pairing key (\(status)).")
        }
    }

    /// Removes the pairing key and leaves the TV certificate pin in place.
    public static func deleteKey(_ host: String) throws {
        let status = SecItemDelete(query(host) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw RemoteError.message("Keychain refused to remove the pairing key (\(status)).")
        }
    }

    public static func delete(_ host: String) throws {
        var failures: [String] = []
        do { try deleteKey(host) }
        catch { failures.append(error.localizedDescription) }
        do { try TVCertificatePin.delete(host) }
        catch { failures.append(error.localizedDescription) }
        if !failures.isEmpty { throw RemoteError.message(failures.joined(separator: " ")) }
    }
}

/// Pins are private to this device and TV, just like the SSAP pairing key.
/// They are never bundled with the app or written into a diagnostic report.
public enum TVCertificatePin {
    private static func query(_ host: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "br.local.LGRemote.Certificate",
            kSecAttrAccount as String: host,
        ]
    }

    public static func read(_ host: String) -> String? {
        var q = query(host)
        q[kSecReturnData as String] = true
        q[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        guard SecItemCopyMatching(q as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data, let pin = String(data: data, encoding: .utf8),
              pin.count == 64, pin.allSatisfy(\.isHexDigit) else { return nil }
        return pin.lowercased()
    }

    public static func save(_ fingerprint: String, host: String) throws {
        let q = query(host)
        let data = Data(fingerprint.utf8)
        let status = SecItemUpdate(q as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if status == errSecItemNotFound {
            var insert = q
            insert[kSecValueData as String] = data
            insert[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            guard SecItemAdd(insert as CFDictionary, nil) == errSecSuccess else {
                throw RemoteError.message("Could not save the TV certificate in Keychain.")
            }
        } else if status != errSecSuccess {
            throw RemoteError.message("Keychain refused the TV certificate (\(status)).")
        }
    }

    public static func delete(_ host: String) throws {
        let status = SecItemDelete(query(host) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw RemoteError.message("Keychain refused to remove the TV certificate (\(status)).")
        }
    }
}
