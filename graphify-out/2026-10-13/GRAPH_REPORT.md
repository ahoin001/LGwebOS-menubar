# Graph Report - LGwebOS-menubar  (2026-10-13)

## Corpus Check
- 69 files · ~109,391 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 809 nodes · 1681 edges · 102 communities (34 shown, 68 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 151 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `cd84577d`
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
- UsageTotal
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
- PictureEditor
- TVIdentity
- VolumeCard
- MediaFileServer.swift

## God Nodes (most connected - your core abstractions)
1. `RemoteCoordinator` - 55 edges
2. `View` - 50 edges
3. `Color` - 39 edges
4. `WebOSConnection` - 36 edges
5. `RemoteError` - 34 edges
6. `TVSession` - 34 edges
7. `Foundation` - 30 edges
8. `LGwebOSCore` - 27 edges
9. `SwiftUI` - 26 edges
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

## Communities (102 total, 68 thin omitted)

### Community 0 - "Certificate approval prompts"
Cohesion: 0.30
Nodes (6): Date, String, URL, UsageJournal, UsageSlice, URL

### Community 1 - "Address and keychain"
Cohesion: 0.12
Nodes (18): PairingKey, Any, String, TVCertificatePin, Any, async, Bool, CheckedContinuation (+10 more)

### Community 2 - "Menu bar app shell"
Cohesion: 0.15
Nodes (10): SettingsScreen, SetupWizard, Bool, String, CastScreen, SettingsScreen, Void, RemoteCoordinator (+2 more)

### Community 3 - "Cast session playback"
Cohesion: 0.09
Nodes (21): Darwin, NSObject, HostAddress, Bool, String, MediaHTTP, Bool, String (+13 more)

### Community 5 - "Pointer channel transport"
Cohesion: 0.11
Nodes (17): AnyObject, Factory, PingResult, PointerChannel, PointerTransport, Bool, CheckedContinuation, Error (+9 more)

### Community 6 - "SSAP command catalog"
Cohesion: 0.10
Nodes (20): Audio, IME, Inputs, Launcher, LaunchPoint, MediaControls, Picture, Pointer (+12 more)

### Community 7 - "Core feature tests"
Cohesion: 0.16
Nodes (5): Bool, Any, Bool, Any, String

### Community 8 - "Certificate trust policy"
Cohesion: 0.10
Nodes (23): Bool, String, TVCertificateDecision, approvalRequired, matched, rejected, TVCertificatePolicy, async (+15 more)

### Community 9 - "iOS feature screens"
Cohesion: 0.12
Nodes (20): ConnectionBanner, RootView, ScreenColumn, Binding, Bool, Content, Void, ActivityScreen (+12 more)

### Community 10 - "Project docs and limits"
Cohesion: 0.10
Nodes (18): Build and run, Compatibility and limits, Connect your TV, Contributing, Diagnostics, Find your TV, iOS, LGwebOS-menubar (+10 more)

### Community 11 - "iOS app sources"
Cohesion: 0.18
Nodes (7): AppKit, LGwebOSChecks, LGwebOSCore, LGwebOSUI, SwiftUI, UniformTypeIdentifiers, XCTest

### Community 12 - "Shared session models"
Cohesion: 0.07
Nodes (18): CryptoKit, Foundation, Observation, Security, ActivityLog, String, URL, Void (+10 more)

### Community 13 - "Privacy check script"
Cohesion: 0.27
Nodes (9): LogEmptyState, LogEntryRow, LogScope, all, commands, connection, LogScopePicker, LogsScreen (+1 more)

### Community 14 - "iOS home and remote"
Cohesion: 0.50
Nodes (4): HomeScreen, Bool, String, Void

### Community 15 - "Remote chrome styling"
Cohesion: 0.09
Nodes (20): ButtonStyle, CaseIterable, RemoteBackground, RemoteButtonStyle, RemoteCard, RemoteDuration, RemotePalette, RemoteSection (+12 more)

### Community 16 - "TV session lifecycle"
Cohesion: 0.23
Nodes (7): async, MainActor, Never, String, Task, Void, TVSession

### Community 17 - "Remote command controller"
Cohesion: 0.28
Nodes (5): RemoteController, Never, String, Task, TVCommanding

### Community 18 - "Shared remote pads"
Cohesion: 0.22
Nodes (11): Image, URL, DirectionalPad, MediaTransportBar, PointerPad, RemoteMetrics, Bool, CGFloat (+3 more)

### Community 19 - "Usage journal persistence"
Cohesion: 0.06
Nodes (40): App, LGwebOSApp, LogDayGroup, LogKind, Bool, Date, Set, String (+32 more)

### Community 20 - "Volume controller"
Cohesion: 0.22
Nodes (6): Bool, Double, Never, Task, Void, VolumeController

### Community 21 - "Usage tracker"
Cohesion: 0.23
Nodes (8): Any, Void, URL, UserDefaults, Int, String, Void, UsageTracker

### Community 22 - "TV app catalog"
Cohesion: 0.32
Nodes (4): Set, String, UserDefaults, TVCatalog

### Community 23 - "Connection teardown"
Cohesion: 0.12
Nodes (14): LocalizedError, FakePointerTransport, FeatureChecks, imageIsValid(), Bool, String, URL, Void (+6 more)

### Community 25 - "Picture controller"
Cohesion: 0.11
Nodes (20): AnyCancellable, ConnectionTrustPrompt, Bool, String, AppDelegate, PanelMetrics, PanelShell, RemotePanel (+12 more)

### Community 26 - "PointerMotion"
Cohesion: 0.24
Nodes (4): PointerMessage, PointerMotion, Int, Int

### Community 27 - "TV identity storage"
Cohesion: 0.53
Nodes (3): PictureController, Int, String

### Community 28 - "UsageTotal"
Cohesion: 0.43
Nodes (5): ActivityScreen, TimeInterval, UsageTotal, AnyView, UsageChart

### Community 29 - "Menu bar remote screen"
Cohesion: 0.12
Nodes (17): Data, FileHandle, NWConnection, NWListener, CastSession, String, URL, DLNATransport (+9 more)

### Community 30 - "iOS picture screen"
Cohesion: 0.09
Nodes (20): PanelArrow, RemoteView, Int, String, Bundle, CGRect, CoreGraphics, ImageIO (+12 more)

### Community 31 - "Bundled image loader"
Cohesion: 0.20
Nodes (9): 1. Check the Mac, 2. Build the app, 3. Collect the TV details, 4. Check compatibility, 5. Check the TV is reachable, 6. Run the offline checks, 7. Connect and pair, LGwebOS-menubar: setup guide for Claude (+1 more)

### Community 35 - ".usageIcon"
Cohesion: 0.16
Nodes (13): BrandAccent, AppsScreen, PictureScreen, Int, String, Configuration, Color, InputRow (+5 more)

### Community 98 - "PictureEditor"
Cohesion: 0.52
Nodes (6): PictureEditor, Binding, Bool, Int, String, Void

### Community 99 - "TVIdentity"
Cohesion: 0.40
Nodes (3): String, UserDefaults, TVIdentity

### Community 100 - "VolumeCard"
Cohesion: 0.53
Nodes (4): Bool, Double, Void, VolumeCard

## Knowledge Gaps
- **111 isolated node(s):** `connection`, `commands`, `all`, `Combine`, `PackageDescription` (+106 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **68 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `RemoteCoordinator` connect `Menu bar app shell` to `Cast session playback`, `Core feature tests`, `iOS feature screens`, `Shared session models`, `Privacy check script`, `iOS home and remote`, `TV session lifecycle`, `Remote command controller`, `Usage journal persistence`, `Volume controller`, `Usage tracker`, `TV app catalog`, `Now playing card`, `Picture controller`, `TV identity storage`, `UsageTotal`, `Menu bar remote screen`, `iOS picture screen`, `.usageIcon`, `TVIdentity`?**
  _High betweenness centrality (0.235) - this node is a cross-community bridge._
- **Why does `WebOSConnection` connect `Address and keychain` to `Pointer channel transport`, `Core feature tests`, `Certificate trust policy`, `TV session lifecycle`, `Connection teardown`, `TV identity storage`?**
  _High betweenness centrality (0.093) - this node is a cross-community bridge._
- **Why does `TVSession` connect `TV session lifecycle` to `Address and keychain`, `Menu bar app shell`, `TVIdentity`, `Core feature tests`, `Shared session models`, `Remote command controller`, `Volume controller`, `Usage tracker`, `TV app catalog`, `TV identity storage`, `Menu bar remote screen`?**
  _High betweenness centrality (0.087) - this node is a cross-community bridge._
- **Are the 7 inferred relationships involving `RemoteCoordinator` (e.g. with `.channel()` and `.send()`) actually correct?**
  _`RemoteCoordinator` has 7 INFERRED edges - model-reasoned connections that need verification._
- **What connects `connection`, `commands`, `all` to the rest of the system?**
  _111 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Address and keychain` be split into smaller, more focused modules?**
  _Cohesion score 0.11904761904761904 - nodes in this community are weakly interconnected._
- **Should `Menu bar app shell` be split into smaller, more focused modules?**
  _Cohesion score 0.14855072463768115 - nodes in this community are weakly interconnected._