import Foundation

/// SSAP reports the underlying app while webOS 5's Home overlay is visible.
/// This tracks a successful Home command, not independently confirmed visibility.
public struct HomePresentation {
    public private(set) var requested = false
    private var underlyingID = ""
    public init() {}
    public mutating func didSendHome(underlyingID: String) {
        requested = true
        self.underlyingID = underlyingID
    }
    public mutating func observe(appID: String) {
        if requested && appID != underlyingID { dismiss() }
    }
    public mutating func dismiss() {
        requested = false
        underlyingID = ""
    }
}
