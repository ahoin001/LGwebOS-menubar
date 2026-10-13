// swift-tools-version: 5.9
import PackageDescription

// Shared TV libraries. The menu bar shell is the macOS app in Apps/macOS.
// It imports AppKit, so it stays out of this package: Xcode would otherwise
// compile it for the iOS scheme and fail with "no such module AppKit".
let package = Package(
    name: "LGwebOSMenubar",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "LGwebOSCore", targets: ["LGwebOSCore"]),
        .library(name: "LGwebOSUI", targets: ["LGwebOSUI"]),
    ],
    targets: [
        .target(
            name: "LGwebOSCore",
            resources: [.copy("registration.json"), .copy("AppAssets"), .copy("app-catalog.json")]
        ),
        .target(name: "LGwebOSUI", dependencies: ["LGwebOSCore"]),
        .testTarget(name: "LGwebOSCoreTests", dependencies: ["LGwebOSCore"]),
    ]
)
