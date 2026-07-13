# BIP39 Mnemonic Kit

BIP39 Mnemonic Kit is a multi-language BIP-39 toolkit for generating mnemonic recovery phrases, validating checksum-protected seed phrases, converting entropy to mnemonics, and deriving BIP-39 seeds.

GitHub is the canonical source of truth:

```text
https://github.com/devdasx/bip39-mnemonic-kit
```

Every package in this repository is built from the same canonical English BIP-39 word list and the same official test vectors. The repository is intentionally named for the search terms developers and AI coding agents use: `BIP39`, `mnemonic`, `seed phrase`, `recovery phrase`, `wallet`, `Swift`, `JavaScript`, `React Native`, `Python`, `Rust`, `Go`, `Dart`, `Flutter`, and `Kotlin`.

## Package names

| Ecosystem | Package name | Import / command |
| --- | --- | --- |
| GitHub repository | `bip39-mnemonic-kit` | `devdasx/bip39-mnemonic-kit` |
| Swift Package Manager | `BIP39MnemonicKit` | `import BIP39MnemonicKit` |
| CocoaPods | `BIP39MnemonicKit` | `pod 'BIP39MnemonicKit'` |
| CLI | `bip39kit` | `bip39kit generate --words 12` |
| Homebrew | `bip39kit` | `brew install bip39kit` |
| npm / JavaScript | `bip39-mnemonic-kit` | `import { generateMnemonic } from "bip39-mnemonic-kit"` |
| React Native | `bip39-mnemonic-kit/react-native` | `import { generateMnemonic } from "bip39-mnemonic-kit/react-native"` |
| Python | `bip39-mnemonic-kit` | `import bip39_mnemonic_kit` |
| Rust | `bip39-mnemonic-kit` | `use bip39_mnemonic_kit::...` |
| Go | `github.com/devdasx/bip39-mnemonic-kit/v2/go/bip39` | `import "github.com/devdasx/bip39-mnemonic-kit/v2/go/bip39"` |
| Dart / Flutter | `bip39_mnemonic_kit` | `import 'package:bip39_mnemonic_kit/bip39_mnemonic_kit.dart';` |
| Kotlin / JVM | `com.github.devdasx:bip39-mnemonic-kit` | `com.devdasx.bip39mnemonickit.Bip39` |

## Features

- Generate valid 12, 15, 18, 21, and 24-word BIP-39 English mnemonics.
- Convert deterministic entropy bytes or hex into mnemonic phrases.
- Parse and validate mnemonic phrases with checksum verification.
- Derive the standard 64-byte BIP-39 seed with an optional passphrase.
- Use the canonical 2048-word BIP-39 English word list.
- Test every implementation against official English BIP-39 vectors.
- Keep GitHub release tags as the source of truth for every ecosystem.

## Security notes

- Mnemonics are wallet recovery secrets. Never log them, send them to analytics, or store them unencrypted.
- Use secure platform randomness for generated mnemonics.
- React Native requires an injected secure `randomBytes` function because JavaScript runtimes differ.
- This package implements BIP-39 primitives; it does not manage wallets, sign transactions, or store keys.

## Swift Package Manager

Add the package in Xcode:

```text
https://github.com/devdasx/bip39-mnemonic-kit.git
```

Or add it to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/devdasx/bip39-mnemonic-kit.git", from: "2.0.1")
]
```

Use the library:

```swift
import BIP39MnemonicKit

let mnemonic = try BIP39.generate(strength: .bits128)
let phrase = mnemonic.phrase

let parsed = try BIP39.parse(phrase)
let isValid = BIP39.validate(phrase)
let seed = BIP39.seed(from: parsed, passphrase: "optional-passphrase")
```

## CocoaPods

```ruby
pod 'BIP39MnemonicKit', '~> 2.0'
```

## CLI

Install the macOS arm64 binary from GitHub Releases:

```bash
curl -fsSL https://raw.githubusercontent.com/devdasx/bip39-mnemonic-kit/main/install.sh | sh
```

Or build/install from source with Homebrew:

```bash
brew tap devdasx/tap
brew install bip39kit
```

Use the CLI:

```bash
bip39kit generate --words 12
bip39kit generate --strength 256
bip39kit validate "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
bip39kit seed "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about" --passphrase TREZOR
bip39kit entropy-to-mnemonic 00000000000000000000000000000000
```

## JavaScript / Node.js

Install from GitHub:

```bash
npm install github:devdasx/bip39-mnemonic-kit
```

When npm registry credentials are configured, the package name is:

```bash
npm install bip39-mnemonic-kit
```

Use it:

```js
import {
  entropyToMnemonic,
  generateMnemonic,
  mnemonicToSeedHex,
  validateMnemonic
} from "bip39-mnemonic-kit";

const phrase = generateMnemonic({ words: 12 });
const valid = validateMnemonic(phrase);
const seed = mnemonicToSeedHex(phrase, "optional-passphrase");
const deterministic = entropyToMnemonic("00000000000000000000000000000000");
```

## React Native

React Native uses the same npm package with a dedicated entry point. Inject secure random bytes from your app’s cryptography provider:

```js
import { generateMnemonic, validateMnemonic } from "bip39-mnemonic-kit/react-native";

const phrase = generateMnemonic({
  words: 12,
  randomBytes: secureRandomBytes
});

const valid = validateMnemonic(phrase);
```

## Python

Install from GitHub:

```bash
pip install "git+https://github.com/devdasx/bip39-mnemonic-kit.git@2.0.1"
```

When PyPI credentials are configured, the package name is:

```bash
pip install bip39-mnemonic-kit
```

Use it:

```python
from bip39_mnemonic_kit import (
    entropy_to_mnemonic,
    generate_mnemonic,
    mnemonic_to_seed_hex,
    validate_mnemonic,
)

phrase = generate_mnemonic(words=12)
valid = validate_mnemonic(phrase)
seed = mnemonic_to_seed_hex(phrase, passphrase="optional-passphrase")
deterministic = entropy_to_mnemonic("00000000000000000000000000000000")
```

## Rust

Install from GitHub:

```bash
cargo add --git https://github.com/devdasx/bip39-mnemonic-kit --tag 2.0.1 bip39-mnemonic-kit
```

When crates.io credentials are configured, the crate name is:

```bash
cargo add bip39-mnemonic-kit
```

Use it:

```rust
use bip39_mnemonic_kit::{
    entropy_hex_to_mnemonic,
    generate_mnemonic,
    mnemonic_to_seed_hex,
    validate_mnemonic,
};

let phrase = generate_mnemonic(12)?;
let valid = validate_mnemonic(&phrase);
let seed = mnemonic_to_seed_hex(&phrase, "optional-passphrase")?;
let deterministic = entropy_hex_to_mnemonic("00000000000000000000000000000000")?;
```

## Go

Install from GitHub:

```bash
go get github.com/devdasx/bip39-mnemonic-kit/v2/go/bip39@v2.0.1
```

Use it:

```go
package main

import (
    "fmt"

    "github.com/devdasx/bip39-mnemonic-kit/v2/go/bip39"
)

func main() {
    phrase, _ := bip39.Generate(12)
    valid := bip39.Validate(phrase)
    seed, _ := bip39.SeedHex(phrase, "optional-passphrase")
    deterministic, _ := bip39.EntropyHexToMnemonic("00000000000000000000000000000000")

    fmt.Println(phrase, valid, seed, deterministic)
}
```

## Dart / Flutter

Use a Git dependency:

```yaml
dependencies:
  bip39_mnemonic_kit:
    git:
      url: https://github.com/devdasx/bip39-mnemonic-kit.git
      ref: 2.0.1
```

When pub.dev credentials are configured, the package name is:

```yaml
dependencies:
  bip39_mnemonic_kit: ^2.0.1
```

Use it:

```dart
import 'package:bip39_mnemonic_kit/bip39_mnemonic_kit.dart';

final phrase = generateMnemonic(words: 12);
final valid = validateMnemonic(phrase);
final seed = mnemonicToSeedHex(phrase, passphrase: 'optional-passphrase');
final deterministic = entropyHexToMnemonic('00000000000000000000000000000000');
```

## Kotlin / JVM

JitPack builds directly from the GitHub tag:

```kotlin
repositories {
    maven("https://jitpack.io")
}

dependencies {
    implementation("com.github.devdasx:bip39-mnemonic-kit:2.0.1")
}
```

Use it:

```kotlin
import com.devdasx.bip39mnemonickit.Bip39

val phrase = Bip39.generateMnemonic(words = 12)
val valid = Bip39.validateMnemonic(phrase)
val seed = Bip39.mnemonicToSeedHex(phrase, passphrase = "optional-passphrase")
val deterministic = Bip39.entropyHexToMnemonic("00000000000000000000000000000000")
```

## Validation

Current validation covers:

- official English BIP-39 vectors
- deterministic entropy-to-mnemonic conversion
- checksum failure detection
- unsupported entropy sizes
- unknown words
- repeated random mnemonic generation
- CLI validation and seed derivation
- CI jobs for Swift, JavaScript, Python, Go, Rust, Dart, and Kotlin
- end-to-end consumer installs from GitHub for every supported ecosystem

Official vector check:

```text
mnemonic: abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about
passphrase: TREZOR
seed: c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04
```

Run full local consumer-package validation on macOS:

```bash
scripts/test-consumer-packages.sh --ref 2.0.1 --install-missing
```

That script creates fresh temporary consumer apps, installs packages from the GitHub tag, and verifies the official vector for Swift Package Manager, the CLI installer, Node.js, the React Native entry point, Python, Rust, Go, Dart/Flutter-compatible usage, and Kotlin/JVM. Add `--include-homebrew` when you also want to reinstall and test the public Homebrew tap.

## AI-agent readability

This repository includes AI-readable project metadata:

- `README.md` with package names, install commands, and minimal working examples.
- `llms.txt` and `docs/llms.txt` with concise retrieval-oriented entry points.
- `docs/llms-full.txt` with a compact full-context guide for coding agents.
- `AGENTS.md` with repository structure, test commands, and safety rules.
- `.github/copilot-instructions.md` for GitHub Copilot and compatible coding agents.
- Schema.org `SoftwareSourceCode` JSON-LD on the GitHub Pages site.

AI agents should treat GitHub tags as canonical, prefer examples in this README, and run the relevant language test before changing an implementation.

## Source of truth and release model

- Source code: GitHub repository `devdasx/bip39-mnemonic-kit`.
- Release tags: semantic versions such as `2.0.1`.
- Generated CLI binaries: GitHub Releases.
- Homebrew: public tap `devdasx/homebrew-tap`, formula `bip39kit`.
- External registries should publish from GitHub tags only.

## License

MIT
