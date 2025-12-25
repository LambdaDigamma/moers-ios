// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "CityOS",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v11),
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
        .library(name: "CoreCache", targets: ["CoreCache"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/hmlongco/Factory", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/LambdaDigamma/ModernNetworking", branch: "main"),
        .package(url: "https://github.com/LambdaDigamma/Resolver", from: "1.1.5"),
        .package(url: "https://github.com/LambdaDigamma/Cache", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/LambdaDigamma/fuse-swift", .upToNextMajor(from: "1.4.2")),
        .package(url: "https://github.com/LambdaDigamma/TagListView", from: "1.4.2"),
        .package(url: "https://github.com/LambdaDigamma/EventBus", from: "0.5.2"),
        .package(url: "https://github.com/LambdaDigamma/TextFieldEffects", branch: "master"),
        .package(url: "https://github.com/LambdaDigamma/app-scaffold-ios", from: "0.1.5"),
        .package(url: "https://github.com/LambdaDigamma/swift-prosemirror", .upToNextMajor(from: "0.0.1")),
        .package(url: "https://github.com/LambdaDigamma/MediaLibraryKit", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/LambdaDigamma/HanekeSwift", .upToNextMajor(from: "0.14.0")),
        .package(url: "https://github.com/nmdias/FeedKit", .upToNextMajor(from: "9.0.0")),
        .package(url: "https://github.com/groue/GRDB.swift", branch: "master"),
        .package(url: "https://github.com/52inc/Pulley", from: "2.9.1"),
        .package(url: "https://github.com/SvenTiigi/YouTubePlayerKit", from: "1.1.1"),
        .package(url: "https://github.com/CoreOffice/XMLCoder", from: "0.14.0"),
        .package(url: "https://github.com/regexident/Gestalt", from: "2.0.0"),
    ],
    targets: [
        // ---------------- Core ----------------
        .target(
            name: "Core",
            dependencies: [
                .product(name: "MediaLibraryKit", package: "MediaLibraryKit"),
                .product(name: "ModernNetworking", package: "ModernNetworking"),
                .product(name: "Fuse", package: "fuse-swift"),
                .product(name: "Resolver", package: "Resolver"),
                .product(name: "Factory", package: "Factory"),
                .product(name: "Gestalt", package: "Gestalt"),
                .product(name: "Haneke", package: "HanekeSwift")
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
        // ---------------- PlaybackKit ----------------
        .target(
            name: "PlaybackKit",
            dependencies: ["Core", "Factory"]
        ),
        .testTarget(
            name: "PlaybackKitTests",
            dependencies: ["WeatherFeature"]
        ),
        // ---------------- WeatherFeature ----------------
        .target(
            name: "WeatherFeature",
            dependencies: ["Core", "Factory"]
        ),
        .testTarget(
            name: "WeatherFeatureTests",
            dependencies: ["WeatherFeature"]
        ),
        // ---------------- RubbishFeature ----------------
        .target(
            name: "RubbishFeature",
            dependencies: ["Core", "ModernNetworking"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "RubbishFeatureTests",
            dependencies: ["RubbishFeature"]
        ),
        // ---------------- ParkingFeature ----------------
        .target(
            name: "ParkingFeature",
            dependencies: ["Core", "ModernNetworking", "Resolver"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "ParkingFeatureTests",
            dependencies: ["ParkingFeature"]
        ),
        // ---------------- DashboardFeature ----------------
        .target(
            name: "DashboardFeature",
            dependencies: [
                "Core", "FuelFeature", "RubbishFeature", "ParkingFeature", "WeatherFeature",
                "EFAAPI", "EFAUI"
            ]
        ),
        .testTarget(
            name: "DashboardFeatureTests",
            dependencies: ["DashboardFeature"]
        ),
        // ---------------- NewsFeature ----------------
        .target(
            name: "NewsFeature",
            dependencies: ["Core", "FeedKit"]
        ),
        .testTarget(
            name: "NewsFeatureTests",
            dependencies: ["NewsFeature"]
        ),
        // ---------------- FuelFeature ----------------
        .target(
            name: "FuelFeature",
            dependencies: [
                "Core",
                .product(name: "Fuse", package: "fuse-swift"),
                .product(name: "ModernNetworking", package: "ModernNetworking"),
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "FuelFeatureTests",
            dependencies: ["FuelFeature"]
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
            ]
        ),
        .testTarget(
            name: "MapFeatureTests",
            dependencies: ["MapFeature"]
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
            ]
        ),
        .testTarget(
            name: "MMEventsTests",
            dependencies: ["MMEvents"]
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
            ]
        ),
        .testTarget(
            name: "MMPagesTests",
            dependencies: ["MMPages"],
            resources: [
                .process("Resources")
            ]
        ),
        // ---------------- MMTours ----------------
        .target(
            name: "MMTours",
            dependencies: [
                .byName(name: "Core")
            ]
        ),
        .testTarget(
            name: "MMToursTests",
            dependencies: ["MMTours"]
        ),
        // ---------------- MMFeeds ----------------
        .target(
            name: "MMFeeds",
            dependencies: [
                .byName(name: "MMPages"),
                .product(name: "ModernNetworking", package: "ModernNetworking"),
                .product(name: "MediaLibraryKit", package: "MediaLibraryKit"),
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
        .testTarget(
            name: "MMFeedsTests",
            dependencies: ["MMFeeds"],
            resources: [
                .process("Resources")
            ]
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
            resources: [.process("Resources")]
        ),
        .target(
            name: "EFAUI",
            dependencies: ["EFAAPI", "Factory", "Core"]
        ),
        .executableTarget(
            name: "EFACLI",
            dependencies: ["EFAAPI", "Factory"]
        ),
        .testTarget(
            name: "EFAAPITests",
            dependencies: ["EFAAPI"],
            resources: [
                .copy("Data")
            ]
        ),
        
    ]
)
