# Graph Report - LGwebOS-menubar  (2026-10-13)

## Corpus Check
- 71 files · ~110,432 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 834 nodes · 1741 edges · 97 communities (29 shown, 68 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 165 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `b3ebd189`
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
- PointerMotion
- TV identity storage
- Menu bar remote screen
- iOS picture screen
- Bundled image loader
- Swift package manifest
- Local build script
- PyWebOSTV registration
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
- TVIdentity

## God Nodes (most connected - your core abstractions)
1. `RemoteCoordinator` - 56 edges
2. `View` - 51 edges
3. `Color` - 39 edges
4. `RemoteError` - 36 edges
5. `WebOSConnection` - 36 edges
6. `TVSession` - 34 edges
7. `Foundation` - 31 edges
8. `SwiftUI` - 27 edges
9. `LGwebOSCore` - 27 edges
10. `RemoteController` - 26 edges

## Surprising Connections (you probably didn't know these)
- `LGwebOSApp` --calls--> `RemoteCoordinator`  [EXTRACTED]
  Apps/iOS/LGwebOS/App/LGwebOSApp.swift → Sources/LGwebOSCore/RemoteCoordinator.swift
- `RootView` --references--> `RemoteCoordinator`  [EXTRACTED]
  Apps/iOS/LGwebOS/App/RootView.swift → Sources/LGwebOSCore/RemoteCoordinator.swift
- `RootView` --references--> `RemoteSection`  [EXTRACTED]
  Apps/iOS/LGwebOS/App/RootView.swift → Sources/LGwebOSUI/RemoteChrome.swift
- `ConnectionBanner` --references--> `RemoteCoordinator`  [EXTRACTED]
  Apps/iOS/LGwebOS/App/RootView.swift → Sources/LGwebOSCore/RemoteCoordinator.swift
- `ActivityScreen` --references--> `RemoteCoordinator`  [EXTRACTED]
  Apps/iOS/LGwebOS/Features/Activity/ActivityScreen.swift → Sources/LGwebOSCore/RemoteCoordinator.swift

## Import Cycles
- None detected.

## Communities (97 total, 68 thin omitted)

### Community 0 - "Certificate approval prompts"
Cohesion: 0.12
Nodes (20): ActivityScreen, ActivityScreen, Equatable, Sendable, BrandIdentity, RGBColor, Bool, Double (+12 more)

### Community 1 - "Address and keychain"
Cohesion: 0.30
Nodes (5): Security, PairingKey, Any, String, TVCertificatePin

### Community 2 - "Menu bar app shell"
Cohesion: 0.15
Nodes (10): SettingsScreen, Binding, Bool, SetupWizard, Bool, String, CastScreen, RemoteCoordinator (+2 more)

### Community 3 - "Cast session playback"
Cohesion: 0.09
Nodes (20): Darwin, NSObject, HostAddress, Bool, String, MediaHTTP, Bool, String (+12 more)

### Community 5 - "Pointer channel transport"
Cohesion: 0.07
Nodes (32): AnyObject, Factory, PingResult, PointerChannel, PointerMessage, PointerTransport, Bool, CheckedContinuation (+24 more)

### Community 6 - "SSAP command catalog"
Cohesion: 0.08
Nodes (26): RegistrationManifest, RegistrationRepair, Any, Bool, String, UserDefaults, Audio, IME (+18 more)

### Community 8 - "Certificate trust policy"
Cohesion: 0.10
Nodes (23): Bool, String, TVCertificateDecision, approvalRequired, matched, rejected, TVCertificatePolicy, async (+15 more)

### Community 9 - "iOS feature screens"
Cohesion: 0.12
Nodes (22): ConnectionBanner, RootView, ScreenColumn, Binding, Bool, Content, Void, AppsScreen (+14 more)

### Community 10 - "Project docs and limits"
Cohesion: 0.10
Nodes (19): Basic and full control, Build and run, Compatibility and limits, Connect your TV, Contributing, Diagnostics, Find your TV, iOS (+11 more)

### Community 11 - "iOS app sources"
Cohesion: 0.11
Nodes (14): AppKit, Combine, CoreGraphics, ImageIO, LGwebOSChecks, LGwebOSCore, LGwebOSUI, ControlAccess (+6 more)

### Community 12 - "Shared session models"
Cohesion: 0.09
Nodes (14): CryptoKit, Foundation, Observation, HomeNavigation, Bool, Set, String, Void (+6 more)

### Community 13 - "Privacy check script"
Cohesion: 0.23
Nodes (11): App, LGwebOSApp, CertificateApproval, CertificateSheet, Prompt, Bool, CheckedContinuation, Never (+3 more)

### Community 14 - "iOS home and remote"
Cohesion: 0.12
Nodes (16): HomeScreen, Bool, String, Void, RemoteView, Int, String, CaseIterable (+8 more)

### Community 15 - "Remote chrome styling"
Cohesion: 0.13
Nodes (12): ButtonStyle, Configuration, RemoteBackground, RemoteButtonStyle, RemoteCard, RemoteDuration, RemotePalette, RemoteSectionTitle (+4 more)

### Community 16 - "TV session lifecycle"
Cohesion: 0.20
Nodes (9): Any, async, Bool, MainActor, Never, String, Task, Void (+1 more)

### Community 17 - "Remote command controller"
Cohesion: 0.18
Nodes (8): PointerMotion, Int, RemoteController, Int, Never, String, Task, TVCommanding

### Community 18 - "Shared remote pads"
Cohesion: 0.06
Nodes (40): BrandAccent, AppsScreen, Bundle, Image, AppResources, BundledImage, URL, BrandTheme (+32 more)

### Community 19 - "Usage journal persistence"
Cohesion: 0.08
Nodes (28): LogDayGroup, LogEmptyState, LogEntryRow, LogKind, LogScope, all, commands, connection (+20 more)

### Community 20 - "Volume controller"
Cohesion: 0.18
Nodes (8): Any, Bool, Double, Never, String, Task, Void, VolumeController

### Community 21 - "Usage tracker"
Cohesion: 0.19
Nodes (9): Any, Void, URL, UserDefaults, Int, String, URL, Void (+1 more)

### Community 22 - "TV app catalog"
Cohesion: 0.31
Nodes (5): TVApp, Set, String, UserDefaults, TVCatalog

### Community 23 - "Connection teardown"
Cohesion: 0.11
Nodes (14): LocalizedError, FakePointerTransport, FeatureChecks, imageIsValid(), Bool, String, URL, Void (+6 more)

### Community 25 - "Picture controller"
Cohesion: 0.12
Nodes (19): AnyCancellable, ConnectionTrustPrompt, Bool, String, AppDelegate, PanelMetrics, PanelShell, RemotePanel (+11 more)

### Community 26 - "PointerMotion"
Cohesion: 0.33
Nodes (4): SettingsScreen, Binding, Bool, Void

### Community 27 - "TV identity storage"
Cohesion: 0.48
Nodes (3): PictureController, Int, String

### Community 29 - "Menu bar remote screen"
Cohesion: 0.10
Nodes (20): Data, FileHandle, Network, NWConnection, NWListener, CastSession, String, URL (+12 more)

### Community 30 - "iOS picture screen"
Cohesion: 0.24
Nodes (8): PanelArrow, CGRect, Path, files_to_check(), findings(), main(), Prefer Git's complete publication view, including newly added files., Shape

### Community 31 - "Bundled image loader"
Cohesion: 0.20
Nodes (9): 1. Check the Mac, 2. Build the app, 3. Collect the TV details, 4. Check compatibility, 5. Check the TV is reachable, 6. Run the offline checks, 7. Connect and pair, LGwebOS-menubar: setup guide for Claude (+1 more)

### Community 99 - "TVIdentity"
Cohesion: 0.33
Nodes (4): Bool, String, UserDefaults, TVIdentity

## Knowledge Gaps
- **113 isolated node(s):** `connection`, `commands`, `all`, `Combine`, `PackageDescription` (+108 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **68 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `RemoteCoordinator` connect `Menu bar app shell` to `Certificate approval prompts`, `Cast session playback`, `iOS feature screens`, `Shared session models`, `Privacy check script`, `iOS home and remote`, `TV session lifecycle`, `Remote command controller`, `Shared remote pads`, `Usage journal persistence`, `Volume controller`, `Usage tracker`, `TV app catalog`, `Now playing card`, `Picture controller`, `PointerMotion`, `TV identity storage`, `Menu bar remote screen`, `TVIdentity`?**
  _High betweenness centrality (0.239) - this node is a cross-community bridge._
- **Why does `WebOSConnection` connect `Pointer channel transport` to `Core feature tests`, `Certificate trust policy`, `TV session lifecycle`, `TV app catalog`, `Connection teardown`, `TV identity storage`?**
  _High betweenness centrality (0.086) - this node is a cross-community bridge._
- **Why does `TVSession` connect `TV session lifecycle` to `Menu bar app shell`, `TVIdentity`, `Pointer channel transport`, `Core feature tests`, `Shared session models`, `Remote command controller`, `Usage journal persistence`, `Volume controller`, `Usage tracker`, `TV app catalog`, `TV identity storage`, `Menu bar remote screen`?**
  _High betweenness centrality (0.086) - this node is a cross-community bridge._
- **Are the 7 inferred relationships involving `RemoteCoordinator` (e.g. with `.channel()` and `.send()`) actually correct?**
  _`RemoteCoordinator` has 7 INFERRED edges - model-reasoned connections that need verification._
- **What connects `connection`, `commands`, `all` to the rest of the system?**
  _113 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Certificate approval prompts` be split into smaller, more focused modules?**
  _Cohesion score 0.11746031746031746 - nodes in this community are weakly interconnected._
- **Should `Cast session playback` be split into smaller, more focused modules?**
  _Cohesion score 0.08522727272727272 - nodes in this community are weakly interconnected._