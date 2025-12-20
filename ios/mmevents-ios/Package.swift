// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "MMEvents",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "MMEvents",
            targets: ["MMEvents"]
        ),
    ],
    dependencies: [
        .package(name: "Core", path: "./../Core"),
        .package(name: "MMPages", path: "./../mmpages-ios"),
        .package(name: "ModernNetworking", url: "https://github.com/lambdadigamma/modernnetworking", from: "1.0.0"),
        .package(name: "GRDB", url: "https://github.com/groue/GRDB.swift", branch: "master"),
        .package(url: "https://github.com/LambdaDigamma/Cache", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "MMEvents",
            dependencies: [
                "Core",
                "MMPages",
                "ModernNetworking",
                "GRDB",
                "Cache",
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "MMEventsTests",
            dependencies: ["MMEvents"]
        ),
    ]
)
