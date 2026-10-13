import Foundation

public enum TVCertificateDecision: Equatable {
    case matched
    case approvalRequired
    case rejected
}

public enum TVCertificatePolicy {
    public static func decide(expected: String?, received: String, canApprove: Bool) -> TVCertificateDecision {
        if let expected { return expected == received ? .matched : .rejected }
        return canApprove ? .approvalRequired : .rejected
    }
}
