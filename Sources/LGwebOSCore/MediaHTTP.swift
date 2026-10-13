import Foundation
import Darwin

public enum MediaHTTP {
    public static func range(_ value: String?, size: UInt64) throws -> (start: UInt64, end: UInt64, partial: Bool) {
        guard size > 0 else { throw RemoteError.message("The file is empty.") }
        guard let value else { return (0, size - 1, false) }
        guard value.hasPrefix("bytes="), !value.contains(",") else { throw RemoteError.message("Invalid byte range.") }
        let parts = value.dropFirst(6).split(separator: "-", omittingEmptySubsequences: false)
        guard parts.count == 2 else { throw RemoteError.message("Invalid byte range.") }
        if parts[0].isEmpty {
            guard let suffix = UInt64(parts[1]), suffix > 0 else { throw RemoteError.message("Invalid byte range.") }
            return (size - min(size, suffix), size - 1, true)
        }
        guard let start = UInt64(parts[0]), start < size else { throw RemoteError.message("Invalid byte range.") }
        let end: UInt64
        if parts[1].isEmpty {
            end = size - 1
        } else {
            guard let parsed = UInt64(parts[1]), parsed >= start else { throw RemoteError.message("Invalid byte range.") }
            end = min(parsed, size - 1)
        }
        return (start, end, true)
    }

    public static func localAddress(for host: String) throws -> String {
        let fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
        guard fd >= 0 else { throw RemoteError.message("Wi-Fi is unavailable.") }
        defer { Darwin.close(fd) }
        var target = sockaddr_in()
        target.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        target.sin_family = sa_family_t(AF_INET)
        target.sin_port = UInt16(1719).bigEndian
        guard inet_pton(AF_INET, host, &target.sin_addr) == 1 else { throw RemoteError.message("Invalid IP address.") }
        let result = withUnsafePointer(to: &target) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                Darwin.connect(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        guard result == 0 else { throw RemoteError.message("There is no network route to the TV.") }
        var local = sockaddr_in()
        var length = socklen_t(MemoryLayout<sockaddr_in>.size)
        _ = withUnsafeMutablePointer(to: &local) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { getsockname(fd, $0, &length) }
        }
        var buffer = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
        guard inet_ntop(AF_INET, &local.sin_addr, &buffer, socklen_t(buffer.count)) != nil else {
            throw RemoteError.message("Could not find this device's IP address.")
        }
        return String(cString: buffer)
    }
}
