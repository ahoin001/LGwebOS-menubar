// swift-tools-version: 5.9
import PackageDescription

// Shared TV libraries. The menu bar shell lives in Apps/macOS, next to its
// Xcode project. It imports AppKit, so it stays out of this package: Xcode
// would otherwise compile it for the iOS scheme and fail with "no such module AppKit".
// LGwebOSChecks is the offline harness. Only the Mac app and the test target link it.
let package = Package(
    name: "LGwebOSMenubar",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "LGwebOSCore", targets: ["LGwebOSCore"]),
        .library(name: "LGwebOSUI", targets: ["LGwebOSUI"]),
        .library(name: "LGwebOSChecks", targets: ["LGwebOSChecks"]),
    ],
    targets: [
        .target(
            name: "LGwebOSCore",
            resources: [.copy("registration.json"), .copy("AppAssets"), .copy("app-catalog.json")]
        ),
        .target(name: "LGwebOSUI", dependencies: ["LGwebOSCore"]),
        .target(name: "LGwebOSChecks", dependencies: ["LGwebOSCore"]),
        .testTarget(name: "LGwebOSCoreTests", dependencies: ["LGwebOSCore", "LGwebOSChecks"]),
    ]
)
