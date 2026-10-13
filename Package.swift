// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LGwebOSMenubar",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "LGwebOSCore", targets: ["LGwebOSCore"]),
        .library(name: "LGwebOSUI", targets: ["LGwebOSUI"]),
        .executable(name: "LGwebOSMenubar", targets: ["LGwebOSMenubar"]),
    ],
    targets: [
        .target(
            name: "LGwebOSCore",
            resources: [.copy("registration.json"), .copy("AppAssets"), .copy("app-catalog.json")]
        ),
        .target(name: "LGwebOSUI", dependencies: ["LGwebOSCore"]),
        .executableTarget(
            name: "LGwebOSMenubar",
            dependencies: ["LGwebOSCore", "LGwebOSUI"]
        ),
        .testTarget(name: "LGwebOSCoreTests", dependencies: ["LGwebOSCore"]),
    ]
)
