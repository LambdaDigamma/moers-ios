// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "WeatherFeature",
    platforms: [.iOS(.v14), .macOS(.v11), .watchOS(.v7), .tvOS(.v14)],
    products: [
        .library(
            name: "WeatherFeature",
            targets: ["WeatherFeature"]
        ),
    ],
    dependencies: [
        .package(name: "Core", path: "../Core"),
    ],
    targets: [
        .target(
            name: "WeatherFeature",
            dependencies: []
        ),
        .testTarget(
            name: "WeatherFeatureTests",
            dependencies: ["WeatherFeature"]
        ),
    ]
)
