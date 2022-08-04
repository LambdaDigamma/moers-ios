// swift-tools-version:5.5
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
        .package(name: "Fuse", url: "https://github.com/LambdaDigamma/fuse-swift", .upToNextMajor(from: "1.4.2")),
        .package(name: "Resolver", url: "https://github.com/LambdaDigamma/Resolver", .upToNextMajor(from: "1.5.1")),
        .package(name: "Cache", url: "https://github.com/LambdaDigamma/Cache", .upToNextMajor(from: "6.0.0")),
        .package(name: "Gestalt", url: "https://github.com/regexident/Gestalt", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: ["MediaLibraryKit", "NukeUI", "ModernNetworking", "Fuse", "Resolver", "Gestalt"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "CoreCache",
            dependencies: ["Core", "Cache"]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core", "CoreCache"]
        ),
    ]
)
