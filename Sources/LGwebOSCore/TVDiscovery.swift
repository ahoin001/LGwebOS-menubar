import Foundation
import Darwin

private final class DeviceXML: NSObject, XMLParserDelegate {
    var values: [String: String] = [:]
    var current = ""
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        current = elementName
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        values[current, default: ""] += string
    }
}

private final class LocalDescriptionSession: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }
}

public enum TVDiscovery {
    public static func search() async -> [TVDevice] {
        await Task.detached(priority: .utility) {
            let fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
            guard fd >= 0 else { return [] }
            defer { Darwin.close(fd) }
            var timeout = timeval(tv_sec: 0, tv_usec: 400_000)
            setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
            var address = sockaddr_in()
            address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            address.sin_family = sa_family_t(AF_INET)
            address.sin_port = UInt16(1900).bigEndian
            inet_pton(AF_INET, "239.255.255.250", &address.sin_addr)
            let message = "M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: \"ssdp:discover\"\r\nMX: 2\r\nST: urn:lge-com:service:webos-second-screen:1\r\n\r\n"
            message.withCString { bytes in
                withUnsafePointer(to: &address) { ptr in
                    ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                        _ = sendto(fd, bytes, strlen(bytes), 0, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
                    }
                }
            }
            var locations = Set<String>()
            let end = Date().addingTimeInterval(4)
            while Date() < end {
                var buffer = [UInt8](repeating: 0, count: 16384)
                var sender = sockaddr_in()
                var senderLength = socklen_t(MemoryLayout<sockaddr_in>.size)
                let count = withUnsafeMutablePointer(to: &sender) { ptr in
                    ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                        recvfrom(fd, &buffer, buffer.count, 0, $0, &senderLength)
                    }
                }
                if count > 0 {
                    var source = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
                    guard inet_ntop(AF_INET, &sender.sin_addr, &source, socklen_t(source.count)) != nil else { continue }
                    let sourceHost = String(cString: source)
                    let text = String(decoding: buffer.prefix(count), as: UTF8.self)
                    for line in text.components(separatedBy: "\r\n") where line.lowercased().hasPrefix("location:") {
                        let location = String(line.dropFirst(9)).trimmingCharacters(in: .whitespaces)
                        guard let url = URL(string: location), url.scheme == "http", url.host == sourceHost,
                              HostAddress.isLocalIPv4(sourceHost), url.user == nil, url.password == nil else { continue }
                        locations.insert(location)
                    }
                }
            }
            var devices: [TVDevice] = []
            let configuration = URLSessionConfiguration.ephemeral
            let session = URLSession(configuration: configuration, delegate: LocalDescriptionSession(), delegateQueue: nil)
            defer { session.invalidateAndCancel() }
            for location in locations {
                guard let url = URL(string: location), let host = url.host, HostAddress.isLocalIPv4(host) else { continue }
                var request = URLRequest(url: url)
                request.timeoutInterval = 4
                guard let (data, response) = try? await session.data(for: request),
                      (response as? HTTPURLResponse)?.statusCode == 200, data.count <= 1_048_576 else { continue }
                let delegate = DeviceXML()
                let parser = XMLParser(data: data)
                parser.delegate = delegate
                parser.shouldResolveExternalEntities = false
                guard parser.parse(), delegate.values["manufacturer", default: ""].contains("LG") else { continue }
                devices.append(TVDevice(
                    host: host,
                    name: delegate.values["friendlyName"] ?? "LG TV",
                    model: delegate.values["modelNumber"] ?? "webOS",
                    mac: nil
                ))
            }
            return devices.sorted { $0.name < $1.name }
        }.value
    }

    public static func wake(mac: String, host: String) throws {
        guard HostAddress.isLocalIPv4(host) else { throw RemoteError.message("Enter the TV's local IPv4 address.") }
        guard HostAddress.isMAC(mac) else { throw RemoteError.message("Invalid MAC address.") }
        let bytes = mac.split(separator: ":").compactMap { UInt8($0, radix: 16) }
        let fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
        guard fd >= 0 else { throw RemoteError.message("Could not send the wake signal.") }
        defer { Darwin.close(fd) }
        var yes: Int32 = 1
        setsockopt(fd, SOL_SOCKET, SO_BROADCAST, &yes, socklen_t(MemoryLayout<Int32>.size))
        let packet = [UInt8](repeating: 255, count: 6) + Array(repeating: bytes, count: 16).flatMap { $0 }
        for target in [host, "255.255.255.255"] {
            var address = sockaddr_in()
            address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            address.sin_family = sa_family_t(AF_INET)
            address.sin_port = UInt16(9).bigEndian
            inet_pton(AF_INET, target, &address.sin_addr)
            let sent = packet.withUnsafeBytes { buffer in
                withUnsafePointer(to: &address) { ptr in
                    ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                        sendto(fd, buffer.baseAddress, packet.count, 0, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
                    }
                }
            }
            if sent < 0 { throw RemoteError.message("Could not send Wake-on-LAN.") }
        }
    }
}
