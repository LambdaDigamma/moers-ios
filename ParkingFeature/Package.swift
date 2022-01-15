// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "ParkingFeature",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "ParkingFeature",
            targets: ["ParkingFeature"]
        ),
    ],
    dependencies: [
        .package(name: "Core", path: "./Core"),
        .package(name: "ModernNetworking",
                 url: "https://github.com/LambdaDigamma/ModernNetworking.git",
                 from: "0.1.2")
    ],
    targets: [
        .target(
            name: "ParkingFeature",
            dependencies: ["Core", "ModernNetworking"]
        ),
        .testTarget(
            name: "ParkingFeatureTests",
            dependencies: ["ParkingFeature"]
        ),
    ]
)
