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
        .package(name: "Core", path: "./Core"),
        .package(url: "https://github.com/hmlongco/Resolver", from: "1.1.4"),
        .package(
            name: "ModernNetworking",
            url: "https://github.com/lambdadigamma/modernnetworking",
            .branch("main")
        )
    ],
    targets: [
        .target(
            name: "RubbishFeature",
            dependencies: ["Core", "Resolver", "ModernNetworking"]
        ),
        .testTarget(
            name: "RubbishFeatureTests",
            dependencies: ["RubbishFeature"]
        ),
    ]
)
