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
        .package(name: "Core", path: "./Core")
    ],
    targets: [
        .target(
            name: "NewsFeature",
            dependencies: ["Core"]
        ),
        .testTarget(
            name: "NewsFeatureTests",
            dependencies: ["NewsFeature"]
        ),
    ]
)
