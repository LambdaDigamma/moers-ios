// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "DashboardFeature",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "DashboardFeature",
            targets: ["DashboardFeature"]
        ),
    ],
    dependencies: [
        .package(name: "RubbishFeature", path: "./RubbishFeature")
    ],
    targets: [
        .target(
            name: "DashboardFeature",
            dependencies: ["RubbishFeature"]
        ),
        .testTarget(
            name: "DashboardFeatureTests",
            dependencies: ["DashboardFeature"]
        ),
    ]
)
