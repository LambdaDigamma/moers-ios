// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "RubbishFeature",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
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
        .package(name: "Core", path: "./Core"),
        .package(
            name: "ModernNetworking",
            url: "https://github.com/LambdaDigamma/ModernNetworking",
            .branch("main")
        )
    ],
    targets: [
        .target(
            name: "RubbishFeature",
            dependencies: ["Core", "ModernNetworking"]
        ),
        .testTarget(
            name: "RubbishFeatureTests",
            dependencies: ["RubbishFeature"]
        ),
    ]
)
