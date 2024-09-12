// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "WeatherFeature",
    platforms: [
        .iOS(.v15),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "WeatherFeature",
            targets: ["WeatherFeature"]
        ),
    ],
    dependencies: [
        .package(name: "Core", path: "../Core"),
        .package(url: "https://github.com/hmlongco/Factory", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        .target(
            name: "WeatherFeature",
            dependencies: ["Core", "Factory"]
        ),
        .testTarget(
            name: "WeatherFeatureTests",
            dependencies: ["WeatherFeature"]
        ),
    ]
)
