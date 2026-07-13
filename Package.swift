// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "BIP39MnemonicKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(
            name: "BIP39MnemonicKit",
            targets: ["BIP39MnemonicKit"]
        ),
        .executable(
            name: "bip39kit",
            targets: ["BIP39KitCLI"]
        ),
    ],
    targets: [
        .target(
            name: "BIP39MnemonicKit",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "BIP39KitCLI",
            dependencies: ["BIP39MnemonicKit"]
        ),
        .testTarget(
            name: "BIP39MnemonicKitTests",
            dependencies: ["BIP39MnemonicKit"],
            resources: [
                .process("Resources")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
