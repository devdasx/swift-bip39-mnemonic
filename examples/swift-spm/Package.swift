// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BIP39MnemonicKitSwiftExample",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/devdasx/bip39-mnemonic-kit.git", exact: "2.0.1")
    ],
    targets: [
        .executableTarget(
            name: "SwiftExample",
            dependencies: [
                .product(name: "BIP39MnemonicKit", package: "bip39-mnemonic-kit")
            ]
        )
    ]
)
