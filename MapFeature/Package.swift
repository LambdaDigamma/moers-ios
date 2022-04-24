// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "MapFeature",
    defaultLocalization: "en",
    platforms: [.iOS(.v14), .macOS(.v11), .watchOS(.v7), .tvOS(.v14)],
    products: [
        .library(
            name: "MapFeature",
            targets: ["MapFeature"]
        ),
    ],
    dependencies: [
        .package(name: "Core", path: "../Core"),
        .package(url: "https://github.com/LambdaDigamma/TagListView", from: "1.4.2"),
        .package(url: "https://github.com/LambdaDigamma/EventBus", from: "0.5.2"),
        .package(url: "https://github.com/LambdaDigamma/TextFieldEffects", branch: "master"),
        .package(url: "https://github.com/LambdaDigamma/mmapi-ios", branch: "master"),
        .package(url: "https://github.com/LambdaDigamma/mmui-ios", branch: "master"),
        .package(url: "https://github.com/52inc/Pulley", from: "2.9.1")
    ],
    targets: [
        .target(
            name: "MapFeature",
            dependencies: [
                .byName(name: "Core"),
                .byName(name: "TagListView"),
                .byName(name: "Pulley"),
                .byName(name: "EventBus"),
                .byName(name: "TextFieldEffects"),
                .product(name: "MMAPI", package: "mmapi-ios"),
                .product(name: "MMUI", package: "mmapi-ios")
            ]
        ),
        .testTarget(
            name: "MapFeatureTests",
            dependencies: ["MapFeature"]
        ),
    ]
)
