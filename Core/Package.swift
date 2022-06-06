// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Core",
    defaultLocalization: "en",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "Core",
            targets: ["Core"]
        ),
        .library(
            name: "CoreCache",
            targets: ["CoreCache"]
        )
    ],
    dependencies: [
        .package(name: "MediaLibraryKit", url: "https://github.com/LambdaDigamma/MediaLibraryKit", .upToNextMajor(from: "0.0.3")),
        .package(name: "NukeUI", url: "https://github.com/kean/NukeUI", .upToNextMajor(from: "0.6.8")),
        .package(name: "ModernNetworking", url: "https://github.com/LambdaDigamma/ModernNetworking", .upToNextMajor(from: "0.1.0")),
        .package(name: "Fuse", url: "https://github.com/lambdadigamma/fuse-swift", .upToNextMajor(from: "1.4.2")),
        .package(name: "Resolver", url: "https://github.com/hmlongco/Resolver", .upToNextMajor(from: "1.3.0"))
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: ["MediaLibraryKit", "NukeUI", "ModernNetworking", "Fuse", "Resolver"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "CoreCache",
            dependencies: ["Core"]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]
        ),
    ]
)
