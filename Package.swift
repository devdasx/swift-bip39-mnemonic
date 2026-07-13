// swift-tools-version: 6.2

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
        .executable(
            name: "swiftbip39",
            targets: ["SwiftBIP39CLI"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftBIP39",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "SwiftBIP39CLI",
            dependencies: ["SwiftBIP39"]
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
