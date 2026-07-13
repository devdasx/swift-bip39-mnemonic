# Agent guide for BIP39 Mnemonic Kit

This repository is a multi-language BIP-39 implementation. GitHub is the source of truth.

## Names

- Repo: `devdasx/bip39-mnemonic-kit`
- Swift: `BIP39MnemonicKit`
- CLI/Homebrew: `bip39kit`
- npm: `bip39-mnemonic-kit`
- Python: `bip39-mnemonic-kit` / `bip39_mnemonic_kit`
- Rust: `bip39-mnemonic-kit` / `bip39_mnemonic_kit`
- Go: `github.com/devdasx/bip39-mnemonic-kit/v2/go/bip39`
- Dart: `bip39_mnemonic_kit`
- Kotlin: `com.github.devdasx:bip39-mnemonic-kit`

## Validate changes

Run the relevant test for the files touched:

```bash
swift test -c release
npm ci && npm test
PYTHONPATH=python python -m unittest discover python/tests
go test ./go/...
cargo test
dart pub get && dart test dart/test
gradle test
```

Before release, run the full GitHub-sourced consumer test suite:

```bash
scripts/test-consumer-packages.sh --ref 2.0.1 --install-missing
```

This creates fresh temporary projects and validates Swift Package Manager, CLI installer, Node.js, React Native entry point, Python, Rust, Go, Dart/Flutter-compatible usage, and Kotlin/JVM.

Run all documentation examples:

```bash
examples/run-examples.sh
```

For CLI changes, also run:

```bash
swift run -c release bip39kit validate "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
swift run -c release bip39kit seed "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about" --passphrase TREZOR
```

## Implementation rules

- Preserve BIP-39 checksum validation exactly.
- Preserve PBKDF2-HMAC-SHA512 seed derivation.
- Preserve the canonical 2048-word English word list.
- Keep package manifests, README, docs site, llms files, and workflows aligned.
- Never add examples that log or store randomly generated real mnemonics.
