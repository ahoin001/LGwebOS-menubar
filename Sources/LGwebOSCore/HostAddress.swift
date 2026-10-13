import Foundation

public enum HostAddress {
    public static func isValidIPv4(_ host: String) -> Bool {
        let parts = host.split(separator: ".", omittingEmptySubsequences: false)
        return parts.count == 4 && parts.allSatisfy {
            !$0.isEmpty && $0.allSatisfy(\.isNumber) && Int($0).map { (0...255).contains($0) } == true
        }
    }

    public static func isMAC(_ mac: String) -> Bool {
        let parts = mac.split(separator: ":", omittingEmptySubsequences: false)
        return parts.count == 6 && parts.allSatisfy { part in
            part.count == 2 && UInt8(part, radix: 16) != nil
        }
    }

    /// Accepts `aa:bb:cc:dd:ee:ff`, dashed, or 12 hex digits, and returns colon form.
    public static func normalizedMAC(_ raw: String) -> String? {
        let hex = raw.uppercased().filter(\.isHexDigit)
        guard hex.count == 12 else { return nil }
        var pairs: [String] = []
        var index = hex.startIndex
        for _ in 0..<6 {
            let next = hex.index(index, offsetBy: 2)
            pairs.append(String(hex[index..<next]))
            index = next
        }
        let formatted = pairs.joined(separator: ":")
        return isMAC(formatted) ? formatted : nil
    }

    public static func isLocalIPv4(_ host: String) -> Bool {
        guard isValidIPv4(host) else { return false }
        let octets = host.split(separator: ".").compactMap { Int($0) }
        return octets[0] == 10
            || (octets[0] == 172 && (16...31).contains(octets[1]))
            || (octets[0] == 192 && octets[1] == 168)
            || (octets[0] == 169 && octets[1] == 254)
    }
}
