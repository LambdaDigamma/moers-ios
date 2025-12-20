// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "ParkingFeature",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
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
        .package(name: "Core", path: "./../Core"),
        .package(url: "https://github.com/LambdaDigamma/Resolver", from: "1.1.5"),
        .package(url: "https://github.com/LambdaDigamma/ModernNetworking", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ParkingFeature",
            dependencies: ["Core", "ModernNetworking", "Resolver"]
        ),
        .testTarget(
            name: "ParkingFeatureTests",
            dependencies: ["ParkingFeature"]
        ),
    ]
)
