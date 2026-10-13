import SwiftUI

public enum ControlAccess {
    public static let basicExplanation = "Basic control does not use the sample certificate, which is why pointer, text entry, and picture changes are unavailable."
    public static let advancedExplanation = "This retries the certificate already built into the app. LG blacklisted that public sample key on webOS 22, including the C2, and does not offer a replacement. Older sets such as the tested UN7310 can still accept it. Enabling it pairs again with that certificate."
}

public struct ControlAccessNote: View {
    private let advanced: Bool
    public init(advanced: Bool) { self.advanced = advanced }
    public var body: some View {
        Text(advanced ? ControlAccess.advancedExplanation : ControlAccess.basicExplanation)
            .font(.system(size: 11))
            .foregroundStyle(RemotePalette.muted)
            .fixedSize(horizontal: false, vertical: true)
    }
}
