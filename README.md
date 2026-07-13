# SwiftBIP39

SwiftBIP39 is a Swift Package Manager library for BIP-39 mnemonic generation, validation, and seed derivation on Apple platforms.

This package is intentionally named for real search terms developers use:

- Swift BIP39
- Swift mnemonic generator
- Swift seed phrase library
- BIP-39 recovery phrase package
- iOS mnemonic / wallet phrase generator

## Features

- Generate valid 12, 15, 18, 21, and 24-word BIP-39 English mnemonics
- Convert entropy bytes into deterministic mnemonic phrases
- Parse and validate mnemonic phrases with checksum verification
- Derive the standard 64-byte BIP-39 seed with optional passphrase
- Bundle the canonical 2048-word BIP-39 English word list
- Avoid third-party Swift package dependencies

## Requirements

- Swift 6.3+
- iOS 15+
- macOS 12+
- tvOS 15+
- watchOS 8+

## Installation

In Xcode:

1. Open your app project.
2. Go to **File > Add Package Dependencies...**
3. Paste:

```text
https://github.com/devdasx/swift-bip39-mnemonic.git
```

4. Add the `SwiftBIP39` library to your target.

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/devdasx/swift-bip39-mnemonic.git", from: "1.0.1")
]
```

## Usage

```swift
import SwiftBIP39

let mnemonic = try BIP39.generate(strength: .bits128)
let phrase = mnemonic.phrase

let parsed = try BIP39.parse(phrase)
let isValid = BIP39.validate(phrase)
let seed = BIP39.seed(from: parsed, passphrase: "optional-passphrase")
```

## API examples

Generate a mnemonic:

```swift
let mnemonic12 = try BIP39.generate(strength: .bits128)
let mnemonic24 = try BIP39.generate(strength: .bits256)
```

Build a mnemonic from known entropy:

```swift
let entropy = Data([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
let mnemonic = try BIP39.mnemonic(from: entropy)
```

Validate a recovery phrase:

```swift
let isValid = BIP39.validate(phrase)
```

Derive a BIP-39 seed:

```swift
let seed = try BIP39.seed(from: phrase, passphrase: "TREZOR")
```

## Validation

This package is tested against the official English BIP-39 reference vectors plus repeated random-generation validation.

Current checks include:

- all 24 official English test vectors
- checksum failure detection
- generation across supported strengths
- repeated random mnemonic generation + validation

## Searchability / discoverability

Repository SEO is handled through:

- a direct standard-based package name: `SwiftBIP39`
- a GitHub repository name targeting the primary query: `swift-bip39-mnemonic`
- README wording that includes BIP-39, mnemonic, seed phrase, recovery phrase, Swift, iOS, and wallet integration terms
- GitHub topics for Swift, BIP39, mnemonic, crypto wallet, and seed phrase searches

## License

MIT
