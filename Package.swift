// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "SwiftBIP39",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(
            name: "SwiftBIP39",
            targets: ["SwiftBIP39"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftBIP39",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SwiftBIP39Tests",
            dependencies: ["SwiftBIP39"],
            resources: [
                .process("Resources")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
