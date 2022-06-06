// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "FuelFeature",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
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
        .package(name: "Core", path: "./Core"),
        .package(name: "Fuse", url: "https://github.com/LambdaDigamma/fuse-swift.git", from: "1.4.1"),
        .package(name: "ModernNetworking", url: "https://github.com/LambdaDigamma/ModernNetworking.git", from: "0.1.2"),
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
