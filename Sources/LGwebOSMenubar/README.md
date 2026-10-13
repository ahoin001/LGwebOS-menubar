# Source notes

`LGwebOSCore` is the shared TV session: SSAP, certificate pinning, discovery, pointer input, casting, and local history. It has no AppKit or UIKit.

`LGwebOSUI` holds the shared SwiftUI pieces: cards, the directional pad, the pointer pad, app marks, volume, picture, and usage. The Mac menu bar and the iOS app compose those pieces separately.

`LGwebOSMenubar` is the macOS app target: the menu bar shell, the command-line checks, and the Mac settings prompts. It is not a Swift package target, because it imports AppKit. Open `LGwebOS.xcworkspace` and run the LGwebOS-menubar scheme on My Mac. New Swift files in this folder also need to be added to `Apps/macOS/LGwebOS-menubar.xcodeproj`.

The only model tested so far is the LG 50UN7310PSC, listed in the repository README. Other models and webOS versions may use different permissions, endpoints, or behavior. Say which TV model and webOS version you tested when you open a pull request that changes how the app talks to the TV.

`registration.json` is the public LG test-client manifest from PyWebOSTV. See `THIRD_PARTY_NOTICES.md` in the repository root.
