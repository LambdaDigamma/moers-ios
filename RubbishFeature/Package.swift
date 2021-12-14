// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "RubbishFeature",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "RubbishFeature",
            targets: ["RubbishFeature"]
        ),
    ],
    dependencies: [
        .package(name: "MMCommon", url: "https://github.com/lambdadigamma/mmcommon-ios", .branch("master")),
        .package(name: "ModernNetworking", url: "https://github.com/lambdadigamma/modernnetworking", .branch("main"))
    ],
    targets: [
        .target(
            name: "RubbishFeature",
            dependencies: ["MMCommon", "ModernNetworking"]
        ),
        .testTarget(
            name: "RubbishFeatureTests",
            dependencies: ["RubbishFeature"]
        ),
    ]
)
