// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "NewsFeature",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
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
        .package(name: "Resolver", url: "https://github.com/hmlongco/Resolver", from: "1.1.4"),
        .package(name: "FeedKit", url: "https://github.com/nmdias/FeedKit.git", .upToNextMajor(from: "9.0.0"))
    ],
    targets: [
        .target(
            name: "NewsFeature",
            dependencies: ["Core", "FeedKit", "Resolver"]
        ),
        .testTarget(
            name: "NewsFeatureTests",
            dependencies: ["NewsFeature"]
        ),
    ]
)
