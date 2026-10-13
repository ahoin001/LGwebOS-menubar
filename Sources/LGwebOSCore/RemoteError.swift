import Foundation

public enum RemoteError: LocalizedError {
    case message(String)
    public var errorDescription: String? {
        if case let .message(text) = self { return text }
        return nil
    }
}
