// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "OparlKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "OparlKit",
            targets: ["OparlKit"]
        ),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "OparlKit",
            dependencies: []
        ),
        .testTarget(
            name: "OparlKitTests",
            dependencies: ["OparlKit"]
        ),
    ]
)
