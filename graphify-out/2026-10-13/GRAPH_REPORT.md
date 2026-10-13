# Graph Report - LGwebOS-menubar  (2026-10-13)

## Corpus Check
- 67 files · ~108,254 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 780 nodes · 1617 edges · 98 communities (31 shown, 67 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 146 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `a57c478e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Certificate approval prompts
- Address and keychain
- Menu bar app shell
- Cast session playback
- Bundled app icons
- Pointer channel transport
- SSAP command catalog
- Core feature tests
- Certificate trust policy
- iOS feature screens
- Project docs and limits
- iOS app sources
- Shared session models
- Privacy check script
- iOS home and remote
- Remote chrome styling
- TV session lifecycle
- Remote command controller
- Shared remote pads
- Usage journal persistence
- Volume controller
- Usage tracker
- TV app catalog
- Connection teardown
- Now playing card
- Picture controller
- Picture editor
- TV identity storage
- Volume card
- Menu bar remote screen
- iOS picture screen
- Bundled image loader
- Swift package manifest
- Local build script
- PyWebOSTV registration
- .usageIcon
- README.md
- Local build script
- Do not guess TV identity
- Pairing lockout caution
- Keep secrets out of git
- Claude setup guide
- AirPlay guidance
- Media casting
- Unverified models stay unverified
- HDMI input switching
- iOS app
- IPv4-only addressing
- No shipped TV identity
- TV pairing
- Picture settings permissions
- Local screen time
- LG 50UN7310PSC
- Wake-on-LAN
- Bundled app icon 06f16e28
- Bundled app icon 0b5e0f3f
- Bundled app icon 0e182343
- Bundled app icon 1d26c8b0
- Bundled app icon 1f28f48f
- Bundled app icon 22eba3dd
- Bundled app icon 3823c035
- Bundled app icon 54505f56
- Bundled app icon 580a3fdc
- Bundled app icon 5945b5da
- Bundled app icon 6851b57a
- Bundled app icon 69f55686
- Bundled app icon 74cfc191
- Bundled app icon 7a4ebb43
- Bundled app icon 7f0ccf32
- Bundled app icon 824c8522
- Bundled app icon 85d4d556
- Bundled app icon 88ece203
- Bundled app icon 8c43158a
- Bundled app icon 96dd253a
- Bundled app icon a2f831ce
- Bundled app icon ac82491c
- Bundled app icon b0b6bad3
- Bundled app icon b350eaa6
- Bundled app icon b4f8bd6c
- Bundled app icon bb4e1793
- Bundled app icon be52d62a
- Bundled app icon c5973575
- Bundled app icon ce52403c
- Bundled app icon d43aa0ce
- Bundled app icon dcea2785
- Bundled app icon e59f18ab
- Bundled app icon e7c8e0f6
- Bundled app icon eaecc4d9
- Bundled app icon eb159a9d
- Bundled app icon f7ab6f6d
- Bundled app icon f8d1682b
- Google Cast symbol
- LG symbol
- PlayStation symbol
- TV hero illustration
- Bundled app icons
- Simple Icons
- tv-hero illustration

## God Nodes (most connected - your core abstractions)
1. `RemoteCoordinator` - 52 edges
2. `View` - 44 edges
3. `Color` - 38 edges
4. `WebOSConnection` - 36 edges
5. `RemoteError` - 34 edges
6. `TVSession` - 34 edges
7. `Foundation` - 30 edges
8. `RemoteController` - 26 edges
9. `LGwebOSCore` - 25 edges
10. `TVCommanding` - 25 edges

## Surprising Connections (you probably didn't know these)
- `LGwebOSApp` --calls--> `RemoteCoordinator`  [EXTRACTED]
  Apps/iOS/LGwebOS/App/LGwebOSApp.swift → Sources/LGwebOSCore/RemoteCoordinator.swift
- `RootView` --references--> `RemoteCoordinator`  [EXTRACTED]
  Apps/iOS/LGwebOS/App/RootView.swift → Sources/LGwebOSCore/RemoteCoordinator.swift
- `RootView` --references--> `View`  [EXTRACTED]
  Apps/iOS/LGwebOS/App/RootView.swift → Sources/LGwebOSUI/RemoteChrome.swift
- `ConnectionBanner` --references--> `RemoteCoordinator`  [EXTRACTED]
  Apps/iOS/LGwebOS/App/RootView.swift → Sources/LGwebOSCore/RemoteCoordinator.swift
- `ActivityScreen` --references--> `RemoteCoordinator`  [EXTRACTED]
  Apps/iOS/LGwebOS/Features/Activity/ActivityScreen.swift → Sources/LGwebOSCore/RemoteCoordinator.swift

## Import Cycles
- None detected.

## Communities (98 total, 67 thin omitted)

### Community 0 - "Certificate approval prompts"
Cohesion: 0.23
Nodes (11): App, LGwebOSApp, CertificateApproval, CertificateSheet, Prompt, Bool, CheckedContinuation, Never (+3 more)

### Community 1 - "Address and keychain"
Cohesion: 0.10
Nodes (21): PairingKey, Any, String, TVCertificatePin, PictureController, Int, String, Any (+13 more)

### Community 2 - "Menu bar app shell"
Cohesion: 0.14
Nodes (10): SettingsScreen, PictureScreen, Int, String, CastScreen, SettingsScreen, Void, RemoteCoordinator (+2 more)

### Community 3 - "Cast session playback"
Cohesion: 0.08
Nodes (24): NSObject, CastSession, String, URL, DLNATransport, String, URL, XMLParser (+16 more)

### Community 5 - "Pointer channel transport"
Cohesion: 0.09
Nodes (20): AnyObject, Factory, PingResult, PointerChannel, PointerMessage, PointerMotion, PointerTransport, Bool (+12 more)

### Community 6 - "SSAP command catalog"
Cohesion: 0.09
Nodes (20): Audio, IME, Inputs, Launcher, LaunchPoint, MediaControls, Picture, Pointer (+12 more)

### Community 8 - "Certificate trust policy"
Cohesion: 0.06
Nodes (42): Codable, CryptoKit, Equatable, Identifiable, Security, Sendable, BrandIdentity, RGBColor (+34 more)

### Community 9 - "iOS feature screens"
Cohesion: 0.14
Nodes (18): ConnectionBanner, ScreenColumn, Content, Void, ActivityScreen, AppsScreen, CastScreen, HomeScreen (+10 more)

### Community 10 - "Project docs and limits"
Cohesion: 0.10
Nodes (18): Build and run, Compatibility and limits, Connect your TV, Contributing, Diagnostics, Find your TV, iOS, LGwebOS-menubar (+10 more)

### Community 11 - "iOS app sources"
Cohesion: 0.11
Nodes (14): AppKit, Combine, LGwebOSChecks, LGwebOSCore, LGwebOSUI, BundledImage, URL, RemoteBackground (+6 more)

### Community 12 - "Shared session models"
Cohesion: 0.08
Nodes (14): Bundle, Foundation, Observation, AppResources, HomeNavigation, Bool, Set, String (+6 more)

### Community 13 - "Privacy check script"
Cohesion: 0.16
Nodes (14): BrandAccent, AppsScreen, HomeScreen, Bool, String, Void, CoreGraphics, BrandTheme (+6 more)

### Community 14 - "iOS home and remote"
Cohesion: 0.12
Nodes (15): RootView, Binding, Bool, RemoteView, Int, String, CaseIterable, RemoteSection (+7 more)

### Community 15 - "Remote chrome styling"
Cohesion: 0.18
Nodes (8): RemoteControlScreen, String, ButtonStyle, Configuration, RemoteButtonStyle, RemoteSectionTitle, Bool, String

### Community 16 - "TV session lifecycle"
Cohesion: 0.14
Nodes (10): Bool, Any, async, Bool, MainActor, Never, String, Task (+2 more)

### Community 17 - "Remote command controller"
Cohesion: 0.27
Nodes (6): RemoteController, Int, Never, String, Task, TVCommanding

### Community 18 - "Shared remote pads"
Cohesion: 0.25
Nodes (10): Image, DirectionalPad, MediaTransportBar, PointerPad, RemoteMetrics, Bool, CGFloat, Int (+2 more)

### Community 19 - "Usage journal persistence"
Cohesion: 0.25
Nodes (9): Date, String, TimeInterval, URL, UsageJournal, UsageSlice, UsageTotal, AnyView (+1 more)

### Community 20 - "Volume controller"
Cohesion: 0.16
Nodes (8): Any, Bool, Double, Never, String, Task, Void, VolumeController

### Community 21 - "Usage tracker"
Cohesion: 0.24
Nodes (7): Any, Void, Int, String, URL, Void, UsageTracker

### Community 22 - "TV app catalog"
Cohesion: 0.32
Nodes (4): Set, String, UserDefaults, TVCatalog

### Community 23 - "Connection teardown"
Cohesion: 0.11
Nodes (18): Darwin, ImageIO, LocalizedError, FakePointerTransport, FeatureChecks, imageIsValid(), Bool, String (+10 more)

### Community 24 - "Now playing card"
Cohesion: 0.43
Nodes (6): InputRow, NowPlayingCard, AnyView, Bool, String, Void

### Community 25 - "Picture controller"
Cohesion: 0.12
Nodes (19): AnyCancellable, ConnectionTrustPrompt, Bool, String, AppDelegate, PanelMetrics, PanelShell, RemotePanel (+11 more)

### Community 26 - "Picture editor"
Cohesion: 0.52
Nodes (6): PictureEditor, Binding, Bool, Int, String, Void

### Community 27 - "TV identity storage"
Cohesion: 0.17
Nodes (9): ActivityLog, String, URL, Void, URL, UserDefaults, String, UserDefaults (+1 more)

### Community 28 - "Volume card"
Cohesion: 0.53
Nodes (4): Bool, Double, Void, VolumeCard

### Community 29 - "Menu bar remote screen"
Cohesion: 0.24
Nodes (11): Data, FileHandle, Network, NWConnection, NWListener, CompletionFlag, MediaFileServer, String (+3 more)

### Community 30 - "iOS picture screen"
Cohesion: 0.24
Nodes (8): PanelArrow, CGRect, Path, files_to_check(), findings(), main(), Prefer Git's complete publication view, including newly added files., Shape

### Community 31 - "Bundled image loader"
Cohesion: 0.20
Nodes (9): 1. Check the Mac, 2. Build the app, 3. Collect the TV details, 4. Check compatibility, 5. Check the TV is reachable, 6. Run the offline checks, 7. Connect and pair, LGwebOS-menubar: setup guide for Claude (+1 more)

### Community 35 - ".usageIcon"
Cohesion: 0.39
Nodes (5): ActivityScreen, AppMark, BrandImage, CGFloat, String

## Knowledge Gaps
- **107 isolated node(s):** `Combine`, `PackageDescription`, `Network`, `message`, `Audio` (+102 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **67 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `RemoteCoordinator` connect `Menu bar app shell` to `Certificate approval prompts`, `Address and keychain`, `.usageIcon`, `Cast session playback`, `Certificate trust policy`, `iOS feature screens`, `Shared session models`, `Privacy check script`, `iOS home and remote`, `Remote chrome styling`, `TV session lifecycle`, `Remote command controller`, `Volume controller`, `Usage tracker`, `TV app catalog`, `Picture controller`, `TV identity storage`?**
  _High betweenness centrality (0.227) - this node is a cross-community bridge._
- **Why does `WebOSConnection` connect `Address and keychain` to `Pointer channel transport`, `SSAP command catalog`, `Certificate trust policy`, `TV session lifecycle`, `Connection teardown`?**
  _High betweenness centrality (0.097) - this node is a cross-community bridge._
- **Why does `TVSession` connect `TV session lifecycle` to `Address and keychain`, `Menu bar app shell`, `Cast session playback`, `Shared session models`, `Remote command controller`, `Volume controller`, `Usage tracker`, `TV app catalog`, `TV identity storage`?**
  _High betweenness centrality (0.087) - this node is a cross-community bridge._
- **Are the 6 inferred relationships involving `RemoteCoordinator` (e.g. with `.channel()` and `.send()`) actually correct?**
  _`RemoteCoordinator` has 6 INFERRED edges - model-reasoned connections that need verification._
- **What connects `Combine`, `PackageDescription`, `Network` to the rest of the system?**
  _107 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Address and keychain` be split into smaller, more focused modules?**
  _Cohesion score 0.09725158562367865 - nodes in this community are weakly interconnected._
- **Should `Menu bar app shell` be split into smaller, more focused modules?**
  _Cohesion score 0.1422924901185771 - nodes in this community are weakly interconnected._