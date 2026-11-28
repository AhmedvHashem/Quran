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
            path: "Sources/InteropSmoke"
        ),
        .executableTarget(
            name: "TilawaMac",
            dependencies: ["Shared"],
            path: "Sources/TilawaMac",
            resources: [
                .process("Resources")
            ],
            // SwiftPM's default build system stamps the deployment target as the
            // SDK version, so AppKit runs the app in pre-macOS 26 compatibility
            // mode: no Liquid Glass sidebar, toolbar or controls. Declare the
            // macOS 26 SDK the app is designed for; the floor stays macOS 13.
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-platform_version", "-Xlinker", "macos", "-Xlinker", "13.0",
                    "-Xlinker", "26.0",
                ])
            ]
        ),
        .binaryTarget(
            name: "Shared",
            path: "../shared/build/XCFrameworks/release/Shared.xcframework"
        ),
    ]
)
