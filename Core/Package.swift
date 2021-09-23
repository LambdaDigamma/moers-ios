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
        .package(name: "MediaLibrary", url: "https://github.com/lambdadigamma/medialibrary-ios", .upToNextMajor(from: "0.0.2")),
        .package(name: "NukeUI", url: "https://github.com/kean/NukeUI", .upToNextMajor(from: "0.6.8")),
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: ["MediaLibrary", "NukeUI"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]
        ),
    ]
)
