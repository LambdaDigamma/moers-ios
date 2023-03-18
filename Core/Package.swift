// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Core",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v12)],
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
        .package(url: "https://github.com/LambdaDigamma/MediaLibraryKit", .upToNextMajor(from: "0.0.3")),
        .package(url: "https://github.com/kean/NukeUI", .upToNextMajor(from: "0.6.8")),
        .package(url: "https://github.com/LambdaDigamma/ModernNetworking", .upToNextMajor(from: "0.1.0")),
        .package(url: "https://github.com/LambdaDigamma/fuse-swift", .upToNextMajor(from: "1.4.2")),
        .package(url: "https://github.com/LambdaDigamma/Resolver", .upToNextMajor(from: "1.5.1")),
        .package(url: "https://github.com/LambdaDigamma/Cache", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/regexident/Gestalt", from: "2.0.0"),
        .package(url: "https://github.com/hmlongco/Factory", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: [
                .product(name: "MediaLibraryKit", package: "MediaLibraryKit"),
                .product(name: "NukeUI", package: "NukeUI"),
                .product(name: "ModernNetworking", package: "ModernNetworking"),
                .product(name: "Fuse", package: "fuse-swift"),
                .product(name: "Resolver", package: "Resolver"),
                .product(name: "Factory", package: "Factory"),
                .product(name: "Gestalt", package: "Gestalt"),
            ],
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
