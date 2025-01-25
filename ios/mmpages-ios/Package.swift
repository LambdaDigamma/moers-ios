// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "MMPages",
    platforms: [
        .iOS(.v15),
        .watchOS(.v7),
        .tvOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "MMPages",
            targets: ["MMPages"]),
    ],
    dependencies: [
        .package(name: "Core", path: "./../Core"),
        .package(name: "ModernNetworking", url: "https://github.com/LambdaDigamma/ModernNetworking", from: "1.0.0"),
        .package(name: "ProseMirror", url: "https://github.com/lambdadigamma/swift-prosemirror", .upToNextMajor(from: "0.0.1")),
        .package(name: "MediaLibraryKit", url: "https://github.com/LambdaDigamma/MediaLibraryKit", .upToNextMajor(from: "0.0.9")),
        .package(url: "https://github.com/SvenTiigi/YouTubePlayerKit", from: "1.1.1"),
        .package(name: "GRDB", url: "https://github.com/groue/GRDB.swift", branch: "master"),
        .package(url: "https://github.com/hmlongco/Factory", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        .target(
            name: "MMPages",
            dependencies: [
                "Core",
                "ModernNetworking",
                "ProseMirror",
                "MediaLibraryKit",
                "YouTubePlayerKit",
                .product(name: "GRDB", package: "GRDB"),
                .product(name: "Factory", package: "Factory")
            ]
        ),
        .testTarget(
            name: "MMPagesTests",
            dependencies: ["MMPages"],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
