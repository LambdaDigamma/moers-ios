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
        .package(url: "https://github.com/hmlongco/Resolver", from: "1.1.4"),
        .package(name: "ModernNetworking",
                 url: "https://github.com/LambdaDigamma/ModernNetworking.git",
                 from: "0.1.2"),
        .package(name: "Charts", url: "https://github.com/spacenation/swiftui-charts", branch: "master"),
    ],
    targets: [
        .target(
            name: "ParkingFeature",
            dependencies: ["Core", "ModernNetworking", "Charts", "Resolver"]
        ),
        .testTarget(
            name: "ParkingFeatureTests",
            dependencies: ["ParkingFeature"]
        ),
    ]
)
