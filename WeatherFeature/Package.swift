// swift-tools-version: 5.6

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
        .package(url: "https://github.com/hmlongco/Factory", .upToNextMajor(from: "1.2.8"))
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
