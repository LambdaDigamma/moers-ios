// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "PlaybackKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
//        .macOS(.v11),
//        .watchOS(.v7),
//        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "PlaybackKit",
            targets: ["PlaybackKit"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "PlaybackKit",
            dependencies: []
        ),
        .testTarget(
            name: "PlaybackKitTests",
            dependencies: ["PlaybackKit"]
        )
    ]
)
