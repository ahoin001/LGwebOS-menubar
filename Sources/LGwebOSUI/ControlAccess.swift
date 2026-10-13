import SwiftUI

public enum ControlAccess {
    public static let basicExplanation = "Apps, inputs, the direction pad, pointer, and keyboard are included when you tap Allow on the TV. Leave this off on a C2. Picture changes can still be refused."
    public static let advancedExplanation = "This sends the sample certificate built into the app. Older sets such as the tested UN7310 can accept it. A current C2 rejects it, and the app turns this switch back off."
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
