// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TilawaMac",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "TilawaMac", targets: ["TilawaMac"])
    ],
    targets: [
        .executableTarget(
            name: "InteropSmoke",
            dependencies: ["Shared"],
            path: "Sources/InteropSmoke"),
        .executableTarget(
            name: "TilawaMac",
            dependencies: ["Shared"],
            path: "Sources/TilawaMac"),
        .binaryTarget(
            name: "Shared",
            path: "../shared/build/XCFrameworks/release/Shared.xcframework"),
    ]
)
