// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "NewsFeature",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "NewsFeature",
            targets: ["NewsFeature"]
        ),
    ],
    dependencies: [
        .package(name: "Core", path: "./Core"),
        .package(name: "FeedKit", url: "https://github.com/nmdias/FeedKit", .upToNextMajor(from: "9.0.0"))
    ],
    targets: [
        .target(
            name: "NewsFeature",
            dependencies: ["Core", "FeedKit"]
        ),
        .testTarget(
            name: "NewsFeatureTests",
            dependencies: ["NewsFeature"]
        ),
    ]
)
