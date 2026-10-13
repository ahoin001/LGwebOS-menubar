# Graph Report - /Users/alexanderhoinville/Desktop/LGwebOS-menubar  (2026-10-13)

## Corpus Check
- 109 files · ~108,040 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 753 nodes · 1661 edges · 35 communities (29 shown, 6 thin omitted)
- Extraction: 88% EXTRACTED · 12% INFERRED · 0% AMBIGUOUS · INFERRED: 193 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

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

## God Nodes (most connected - your core abstractions)
1. `RemoteCoordinator` - 53 edges
2. `View` - 44 edges
3. `Bundled app icons` - 39 edges
4. `Color` - 38 edges
5. `WebOSConnection` - 37 edges
6. `TVSession` - 35 edges
7. `RemoteError` - 34 edges
8. `Foundation` - 30 edges
9. `RemoteController` - 26 edges
10. `TVCommanding` - 25 edges

## Surprising Connections (you probably didn't know these)
- `HDMI input switching` --conceptually_related_to--> `RemoteCoordinator`  [INFERRED]
  README.md → Sources/LGwebOSCore/RemoteCoordinator.swift
- `TV pairing` --conceptually_related_to--> `TVSession`  [INFERRED]
  README.md → Sources/LGwebOSCore/TVSession.swift
- `TV pairing` --conceptually_related_to--> `WebOSConnection`  [INFERRED]
  README.md → Sources/LGwebOSCore/WebOSConnection.swift
- `Bundled app icon 03eaf5a5` --references--> `Bundled app icons`  [INFERRED]
  Sources/LGwebOSCore/AppAssets/03eaf5a591c43139f8.png → THIRD_PARTY_NOTICES.md
- `Bundled app icon 06f16e28` --references--> `Bundled app icons`  [INFERRED]
  Sources/LGwebOSCore/AppAssets/06f16e28ffec86908c.png → THIRD_PARTY_NOTICES.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Shared TV client architecture** — sources_lgwebosmenubar_readme_core, sources_lgwebosmenubar_readme_ui, sources_lgwebosmenubar_readme_menubar, readme_ios_app [EXTRACTED 1.00]

## Communities (35 total, 6 thin omitted)

### Community 0 - "Certificate approval prompts"
Cohesion: 0.06
Nodes (38): CertificateApproval, CertificateSheet, Prompt, Bool, CheckedContinuation, Never, String, Void (+30 more)

### Community 1 - "Address and keychain"
Cohesion: 0.07
Nodes (30): LocalizedError, HostAddress, Bool, String, PairingKey, Any, String, TVCertificatePin (+22 more)

### Community 2 - "Menu bar app shell"
Cohesion: 0.07
Nodes (29): AnyCancellable, RemoteScreen, String, SettingsScreen, Combine, Notification, NSApplication, NSApplicationDelegate (+21 more)

### Community 3 - "Cast session playback"
Cohesion: 0.09
Nodes (24): Data, FileHandle, Network, NSObject, NWConnection, NWListener, CastSession, String (+16 more)

### Community 4 - "Bundled app icons"
Cohesion: 0.05
Nodes (43): Bundled app icon 03eaf5a5, Bundled app icon 06f16e28, Bundled app icon 0b5e0f3f, Bundled app icon 0e182343, Bundled app icon 1d26c8b0, Bundled app icon 1f28f48f, Bundled app icon 22eba3dd, Bundled app icon 3823c035 (+35 more)

### Community 5 - "Pointer channel transport"
Cohesion: 0.09
Nodes (20): AnyObject, Factory, PingResult, PointerChannel, PointerMessage, PointerMotion, PointerTransport, Bool (+12 more)

### Community 6 - "SSAP command catalog"
Cohesion: 0.09
Nodes (20): Audio, IME, Inputs, Launcher, LaunchPoint, MediaControls, Picture, Pointer (+12 more)

### Community 7 - "Core feature tests"
Cohesion: 0.14
Nodes (10): FakePointerTransport, FeatureChecks, imageIsValid(), Bool, String, URL, Void, HomePresentation (+2 more)

### Community 8 - "Certificate trust policy"
Cohesion: 0.09
Nodes (25): CryptoKit, Security, Bool, String, TVCertificateDecision, approvalRequired, matched, rejected (+17 more)

### Community 9 - "iOS feature screens"
Cohesion: 0.12
Nodes (23): ConnectionBanner, ScreenColumn, Content, Void, ActivityScreen, AppsScreen, CastScreen, HomeScreen (+15 more)

### Community 10 - "Project docs and limits"
Cohesion: 0.08
Nodes (28): App, LGwebOSApp, Local build script, Do not guess TV identity, Pairing lockout caution, Keep secrets out of git, Claude setup guide, AirPlay guidance (+20 more)

### Community 11 - "iOS app sources"
Cohesion: 0.17
Nodes (8): AppKit, CoreGraphics, ImageIO, LGwebOSCore, LGwebOSUI, SwiftUI, UIKit, UniformTypeIdentifiers

### Community 12 - "Shared session models"
Cohesion: 0.11
Nodes (10): Darwin, Foundation, Observation, HomeNavigation, Bool, Set, String, Void (+2 more)

### Community 13 - "Privacy check script"
Cohesion: 0.11
Nodes (16): BrandAccent, Bundle, CGRect, Path, files_to_check(), findings(), main(), Prefer Git's complete publication view, including newly added files. (+8 more)

### Community 14 - "iOS home and remote"
Cohesion: 0.10
Nodes (19): RootView, Binding, Bool, CaseIterable, HomeScreen, Bool, String, Void (+11 more)

### Community 15 - "Remote chrome styling"
Cohesion: 0.13
Nodes (12): ButtonStyle, Configuration, RemoteBackground, RemoteButtonStyle, RemoteCard, RemoteDuration, RemotePalette, RemoteSectionTitle (+4 more)

### Community 16 - "TV session lifecycle"
Cohesion: 0.20
Nodes (8): Any, async, MainActor, Never, String, Task, Void, TVSession

### Community 17 - "Remote command controller"
Cohesion: 0.22
Nodes (8): RemoteController, Any, Int, Never, String, Task, Void, TVCommanding

### Community 18 - "Shared remote pads"
Cohesion: 0.27
Nodes (12): Color, AnyView, UsageChart, DirectionalPad, MediaTransportBar, PointerPad, RemoteMetrics, Bool (+4 more)

### Community 19 - "Usage journal persistence"
Cohesion: 0.30
Nodes (6): Date, String, URL, UsageJournal, UsageSlice, URL

### Community 20 - "Volume controller"
Cohesion: 0.16
Nodes (8): Any, Bool, Double, Never, String, Task, Void, VolumeController

### Community 21 - "Usage tracker"
Cohesion: 0.29
Nodes (6): URL, UserDefaults, Int, String, Void, UsageTracker

### Community 22 - "TV app catalog"
Cohesion: 0.29
Nodes (5): TVApp, Set, String, UserDefaults, TVCatalog

### Community 24 - "Now playing card"
Cohesion: 0.43
Nodes (6): InputRow, NowPlayingCard, AnyView, Bool, String, Void

### Community 25 - "Picture controller"
Cohesion: 0.48
Nodes (3): PictureController, Int, String

### Community 26 - "Picture editor"
Cohesion: 0.52
Nodes (6): PictureEditor, Binding, Bool, Int, String, Void

### Community 27 - "TV identity storage"
Cohesion: 0.40
Nodes (3): String, UserDefaults, TVIdentity

### Community 28 - "Volume card"
Cohesion: 0.53
Nodes (4): Bool, Double, Void, VolumeCard

### Community 30 - "iOS picture screen"
Cohesion: 0.67
Nodes (3): PictureScreen, Int, String

## Knowledge Gaps
- **76 isolated node(s):** `PackageDescription`, `Network`, `message`, `Audio`, `Launcher` (+71 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `RemoteCoordinator` connect `Menu bar app shell` to `Certificate approval prompts`, `Cast session playback`, `iOS feature screens`, `Project docs and limits`, `Shared session models`, `Privacy check script`, `iOS home and remote`, `TV session lifecycle`, `Remote command controller`, `Volume controller`, `Usage tracker`, `TV app catalog`, `Picture controller`, `TV identity storage`, `Menu bar remote screen`, `iOS picture screen`?**
  _High betweenness centrality (0.282) - this node is a cross-community bridge._
- **Why does `WebOSConnection` connect `Address and keychain` to `Pointer channel transport`, `Certificate trust policy`, `Project docs and limits`, `TV session lifecycle`, `TV app catalog`, `Connection teardown`, `Picture controller`?**
  _High betweenness centrality (0.123) - this node is a cross-community bridge._
- **Why does `TVSession` connect `TV session lifecycle` to `Certificate approval prompts`, `Address and keychain`, `Menu bar app shell`, `Cast session playback`, `Project docs and limits`, `Shared session models`, `Remote command controller`, `Volume controller`, `Usage tracker`, `TV app catalog`, `Connection teardown`, `Picture controller`, `TV identity storage`?**
  _High betweenness centrality (0.112) - this node is a cross-community bridge._
- **Are the 7 inferred relationships involving `RemoteCoordinator` (e.g. with `.channel()` and `.send()`) actually correct?**
  _`RemoteCoordinator` has 7 INFERRED edges - model-reasoned connections that need verification._
- **Are the 38 inferred relationships involving `Bundled app icons` (e.g. with `Bundled app icon 03eaf5a5` and `Bundled app icon 06f16e28`) actually correct?**
  _`Bundled app icons` has 38 INFERRED edges - model-reasoned connections that need verification._
- **Are the 2 inferred relationships involving `WebOSConnection` (e.g. with `TV pairing` and `WebSocketPointerTransport`) actually correct?**
  _`WebOSConnection` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `Network`, `message` to the rest of the system?**
  _76 weakly-connected nodes found - possible documentation gaps or missing edges._