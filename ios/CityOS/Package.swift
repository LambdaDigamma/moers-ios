// swift-tools-version: 6.2

import PackageDescription

let settings: [SwiftSetting] = [
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances")
]

let package = Package(
    name: "CityOS",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(name: "WeatherFeature", targets: ["WeatherFeature"]),
        .library(name: "RubbishFeature", targets: ["RubbishFeature"]),
        .library(name: "ParkingFeature", targets: ["ParkingFeature"]),
        .library(name: "DashboardFeature", targets: ["DashboardFeature"]),
        .library(name: "NewsFeature", targets: ["NewsFeature"]),
        .library(name: "FuelFeature", targets: ["FuelFeature"]),
        .library(name: "MapFeature", targets: ["MapFeature"]),
        .library(name: "PlaybackKit", targets: ["PlaybackKit"]),
        .library(name: "MMEvents", targets: ["MMEvents"]),
        .library(name: "MMPages", targets: ["MMPages"]),
        .library(name: "MMTours", targets: ["MMTours"]),
        .library(name: "MMFeeds", targets: ["MMFeeds"]),
        .library(name: "EFAAPI", targets: ["EFAAPI"]),
        .library(name: "EFAUI", targets: ["EFAUI"]),
        .executable(name: "EFACLI", targets: ["EFACLI"]),
        .library(name: "Core", targets: ["Core"]),
        .library(name: "CoreCache", targets: ["CoreCache"]),
        .library(name: "Pulley", targets: ["Pulley"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/hmlongco/Factory", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/LambdaDigamma/ModernNetworking", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/hyperoslo/Cache", .upToNextMajor(from: "7.4.0")),
        .package(url: "https://github.com/LambdaDigamma/fuse-swift", .upToNextMajor(from: "1.4.2")),
        .package(url: "https://github.com/LambdaDigamma/TagListView", from: "1.4.2"),
        .package(url: "https://github.com/LambdaDigamma/EventBus", from: "0.5.2"),
        .package(url: "https://github.com/LambdaDigamma/TextFieldEffects", branch: "master"),
        .package(url: "https://github.com/LambdaDigamma/app-scaffold-ios", from: "1.0.0"),
        .package(url: "https://github.com/LambdaDigamma/swift-prosemirror", .upToNextMajor(from: "0.0.8")),
        .package(url: "https://github.com/LambdaDigamma/MediaLibraryKit", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/LambdaDigamma/HanekeSwift", .upToNextMajor(from: "0.14.0")),
        .package(url: "https://github.com/nmdias/FeedKit", .upToNextMajor(from: "10.4.0")),
        .package(url: "https://github.com/groue/GRDB.swift", .upToNextMajor(from: "7.9.0")),
        .package(url: "https://github.com/SvenTiigi/YouTubePlayerKit", from: "2.0.0"),
        .package(url: "https://github.com/CoreOffice/XMLCoder", from: "0.18.0"),
    ],
    targets: [
        // ---------------- Core ----------------
        .target(
            name: "Core",
            dependencies: [
                .product(name: "MediaLibraryKit", package: "MediaLibraryKit"),
                .product(name: "ModernNetworking", package: "ModernNetworking"),
                .product(name: "Fuse", package: "fuse-swift"),
                .product(name: "Factory", package: "Factory"),
                .product(name: "Haneke", package: "HanekeSwift")
            ],
            resources: [.process("Resources")],
            swiftSettings: settings
        ),
        .target(
            name: "CoreCache",
            dependencies: ["Core", "Cache"],
            swiftSettings: settings
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core", "CoreCache"],
            swiftSettings: settings
        ),
        // ---------------- PlaybackKit ----------------
        .target(
            name: "PlaybackKit",
            dependencies: ["Core", "Factory"],
            swiftSettings: settings
        ),
        .testTarget(
            name: "PlaybackKitTests",
            dependencies: ["WeatherFeature"],
            swiftSettings: settings
        ),
        // ---------------- WeatherFeature ----------------
        .target(
            name: "WeatherFeature",
            dependencies: ["Core", "Factory"],
            swiftSettings: settings
        ),
        .testTarget(
            name: "WeatherFeatureTests",
            dependencies: ["WeatherFeature"],
            swiftSettings: settings
        ),
        // ---------------- RubbishFeature ----------------
        .target(
            name: "RubbishFeature",
            dependencies: ["Core", "ModernNetworking"],
            resources: [
                .process("Resources")
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "RubbishFeatureTests",
            dependencies: ["RubbishFeature"],
            swiftSettings: settings
        ),
        // ---------------- ParkingFeature ----------------
        .target(
            name: "ParkingFeature",
            dependencies: ["Core", "ModernNetworking"],
            resources: [
                .process("Resources")
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "ParkingFeatureTests",
            dependencies: ["ParkingFeature"],
            swiftSettings: settings
        ),
        // ---------------- DashboardFeature ----------------
        .target(
            name: "DashboardFeature",
            dependencies: [
                "Core", "FuelFeature", "RubbishFeature", "ParkingFeature", "WeatherFeature",
                "EFAAPI", "EFAUI"
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "DashboardFeatureTests",
            dependencies: ["DashboardFeature"],
            swiftSettings: settings
        ),
        // ---------------- NewsFeature ----------------
        .target(
            name: "NewsFeature",
            dependencies: ["Core", "FeedKit"],
            swiftSettings: settings
        ),
        .testTarget(
            name: "NewsFeatureTests",
            dependencies: ["NewsFeature"],
            swiftSettings: settings
        ),
        // ---------------- FuelFeature ----------------
        .target(
            name: "FuelFeature",
            dependencies: [
                "Core",
                .product(name: "Fuse", package: "fuse-swift"),
                .product(name: "ModernNetworking", package: "ModernNetworking"),
            ],
            resources: [.process("Resources")],
            swiftSettings: settings
        ),
        .testTarget(
            name: "FuelFeatureTests",
            dependencies: ["FuelFeature"],
            swiftSettings: settings
        ),
        // ---------------- MapFeature ----------------
        .target(
            name: "MapFeature",
            dependencies: [
                .product(name: "AppScaffold", package: "app-scaffold-ios"),
                .byName(name: "Core"),
                .byName(name: "TagListView"),
                .byName(name: "Pulley"),
                .byName(name: "EventBus"),
                .byName(name: "TextFieldEffects"),
                .byName(name: "FuelFeature"),
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "MapFeatureTests",
            dependencies: ["MapFeature"],
            swiftSettings: settings
        ),
        
        // ---------------- MMEvents ----------------
        .target(
            name: "MMEvents",
            dependencies: [
                "Core",
                "MMPages",
                "ModernNetworking",
                "Cache",
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections")
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "MMEventsTests",
            dependencies: ["MMEvents"],
            swiftSettings: settings
        ),
        // ---------------- MMPages ----------------
        .target(
            name: "MMPages",
            dependencies: [
                "Core",
                "ModernNetworking",
                "MediaLibraryKit",
                "YouTubePlayerKit",
                .product(name: "ProseMirror", package: "swift-prosemirror"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Factory", package: "Factory")
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "MMPagesTests",
            dependencies: ["MMPages"],
            resources: [
                .process("Resources")
            ],
            swiftSettings: settings
        ),
        // ---------------- MMTours ----------------
        .target(
            name: "MMTours",
            dependencies: [
                .byName(name: "Core")
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "MMToursTests",
            dependencies: ["MMTours"],
            swiftSettings: settings
        ),
        // ---------------- MMFeeds ----------------
        .target(
            name: "MMFeeds",
            dependencies: [
                .byName(name: "MMPages"),
                .product(name: "ModernNetworking", package: "ModernNetworking"),
                .product(name: "MediaLibraryKit", package: "MediaLibraryKit"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Cache", package: "Cache")
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "MMFeedsTests",
            dependencies: ["MMFeeds"],
            resources: [
                .process("Resources")
            ],
            swiftSettings: settings
        ),
        
        // ---------------- EFAAPI ----------------
        .target(
            name: "EFAAPI",
            dependencies: [
                "XMLCoder",
                "ModernNetworking",
                "Factory",
                "Core"
            ],
            resources: [.process("Resources")],
            swiftSettings: settings
        ),
        .target(
            name: "EFAUI",
            dependencies: ["EFAAPI", "Factory", "Core"],
            swiftSettings: settings
        ),
        .executableTarget(
            name: "EFACLI",
            dependencies: ["EFAAPI", "Factory"],
            swiftSettings: settings
        ),
        .testTarget(
            name: "EFAAPITests",
            dependencies: ["EFAAPI"],
            resources: [
                .copy("Data")
            ],
            swiftSettings: settings
        ),
        .target(
            name: "Pulley",
            swiftSettings: settings
        )
    ]
)
