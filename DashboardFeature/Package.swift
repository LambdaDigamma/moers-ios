// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "DashboardFeature",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "DashboardFeature",
            targets: ["DashboardFeature"]
        ),
    ],
    dependencies: [
        .package(name: "Core", path: "../Core"),
        .package(name: "FuelFeature", path: "../FuelFeature"),
        .package(name: "RubbishFeature", path: "../RubbishFeature"),
        .package(name: "ParkingFeature", path: "../ParkingFeature"),
        .package(name: "WeatherFeature", path: "../WeatherFeature"),
        .package(path: "../efaapi-ios")
    ],
    targets: [
        .target(
            name: "DashboardFeature",
            dependencies: [
                "Core", "FuelFeature", "RubbishFeature", "ParkingFeature", "WeatherFeature",
                .product(name: "EFAAPI", package: "efaapi-ios"),
                .product(name: "EFAUI", package: "efaapi-ios")
            ]
        ),
        .testTarget(
            name: "DashboardFeatureTests",
            dependencies: ["DashboardFeature"]
        ),
    ]
)
