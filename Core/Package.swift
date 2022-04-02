// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Core",
    defaultLocalization: "en",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Core",
            targets: ["Core"]
        ),
    ],
    dependencies: [
        .package(name: "MediaLibraryKit", url: "https://github.com/LambdaDigamma/MediaLibraryKit", .upToNextMajor(from: "0.0.3")),
        .package(name: "NukeUI", url: "https://github.com/kean/NukeUI", .upToNextMajor(from: "0.6.8")),
        .package(name: "ModernNetworking", url: "https://github.com/LambdaDigamma/ModernNetworking", .upToNextMajor(from: "0.1.0"))
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: ["MediaLibraryKit", "NukeUI", "ModernNetworking"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]
        ),
    ]
)
