// swift-tools-version:5.9

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
        .package(url: "https://github.com/LambdaDigamma/fuse-swift", from: "1.4.1"),
        .package(url: "https://github.com/LambdaDigamma/ModernNetworking", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FuelFeature",
            dependencies: [
                .product(name: "Core", package: "Core"),
                .product(name: "Fuse", package: "fuse-swift"),
                .product(name: "ModernNetworking", package: "ModernNetworking"),
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "FuelFeatureTests",
            dependencies: ["FuelFeature"]
        ),
    ]
)
