import Foundation

private final class TransportXML: NSObject, XMLParserDelegate {
    var path: String?
    private var inside = false
    private var element = ""
    private var values: [String: String] = [:]

    func parser(_ parser: XMLParser, didStartElement name: String, namespaceURI: String?, qualifiedName: String?, attributes: [String: String]) {
        if name == "service" { inside = true; values = [:] }
        element = name
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if inside { values[element, default: ""] += string }
    }

    func parser(_ parser: XMLParser, didEndElement name: String, namespaceURI: String?, qualifiedName: String?) {
        if name == "service" {
            if values["serviceType"]?.contains(":AVTransport:") == true {
                path = values["controlURL"]?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            inside = false
        }
        element = ""
    }
}

public enum DLNATransport {
    public static let urn = "urn:schemas-upnp-org:service:AVTransport:1"

    public static func discover(host: String) async throws -> URL {
        guard HostAddress.isValidIPv4(host), let url = URL(string: "http://\(host):1719/") else {
            throw RemoteError.message("Invalid IP address.")
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 6
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw RemoteError.message("The TV's media service did not respond.")
        }
        let parser = XMLParser(data: data)
        let delegate = TransportXML()
        parser.delegate = delegate
        guard parser.parse(), let path = delegate.path, let control = URL(string: path, relativeTo: url)?.absoluteURL,
              control.host == host, control.scheme == "http", control.port == 1719 else {
            throw RemoteError.message("No compatible media service was found on this TV.")
        }
        return control
    }

    public static func escape(_ text: String) -> String {
        text.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }

    public static func metadata(url: URL, title: String, mime: String) -> String {
        let type = mime.hasPrefix("image/") ? "imageItem.photo" : mime.hasPrefix("audio/") ? "audioItem.musicTrack" : "videoItem"
        return "<DIDL-Lite xmlns=\"urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:upnp=\"urn:schemas-upnp-org:metadata-1-0/upnp/\"><item id=\"0\" parentID=\"-1\" restricted=\"1\"><dc:title>\(escape(title))</dc:title><upnp:class>object.item.\(type)</upnp:class><res protocolInfo=\"http-get:*:\(escape(mime)):*\">\(escape(url.absoluteString))</res></item></DIDL-Lite>"
    }

    public static func envelope(action: String, parameters: [(String, String)]) -> String {
        let arguments = ([("InstanceID", "0")] + parameters).map { "<\($0.0)>\(escape($0.1))</\($0.0)>" }.joined()
        return "<?xml version=\"1.0\" encoding=\"utf-8\"?><s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><s:Body><u:\(action) xmlns:u=\"\(urn)\">\(arguments)</u:\(action)></s:Body></s:Envelope>"
    }

    public static func command(_ url: URL, action: String, parameters: [(String, String)] = []) async throws -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.setValue("text/xml; charset=\"utf-8\"", forHTTPHeaderField: "Content-Type")
        request.setValue("\"\(urn)#\(action)\"", forHTTPHeaderField: "SOAPAction")
        request.httpBody = Data(envelope(action: action, parameters: parameters).utf8)
        let (data, response) = try await URLSession.shared.data(for: request)
        let text = String(decoding: data, as: UTF8.self)
        guard (response as? HTTPURLResponse)?.statusCode == 200, !text.contains("Fault>") else {
            throw RemoteError.message("The TV rejected \(action). Check the file format and connection.")
        }
        return text
    }
}
