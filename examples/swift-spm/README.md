# Swift Package Manager example

This example installs `BIP39MnemonicKit` from GitHub and runs a small Swift executable.

## Install

Add the package to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/devdasx/bip39-mnemonic-kit.git", exact: "2.0.1")
]
```

Then add the product to your target:

```swift
.product(name: "BIP39MnemonicKit", package: "bip39-mnemonic-kit")
```

## Run

```bash
swift run -c release
```

## What it does

- Converts known entropy into the official BIP-39 mnemonic.
- Validates the mnemonic checksum.
- Rejects a bad checksum phrase.
- Derives the official BIP-39 seed with passphrase `TREZOR`.
- Generates a new 12-word mnemonic.
