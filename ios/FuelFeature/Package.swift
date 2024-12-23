// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "FuelFeature",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FuelFeature",
            targets: ["FuelFeature"]
        ),
    ],
    dependencies: [
        .package(name: "Core", path: "./../Core"),
        .package(name: "Fuse", url: "https://github.com/LambdaDigamma/fuse-swift", from: "1.4.1"),
        .package(name: "ModernNetworking", url: "https://github.com/LambdaDigamma/ModernNetworking", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FuelFeature",
            dependencies: ["Core", "Fuse", "ModernNetworking"]
        ),
        .testTarget(
            name: "FuelFeatureTests",
            dependencies: ["FuelFeature"]
        ),
    ]
)
