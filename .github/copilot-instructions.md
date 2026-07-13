# Copilot instructions for BIP39 Mnemonic Kit

This is a multi-language BIP-39 mnemonic package. Keep behavior consistent across Swift, JavaScript, React Native, Python, Rust, Go, Dart/Flutter, and Kotlin.

Prefer the package names documented in `README.md`:

- Swift: `BIP39MnemonicKit`
- CLI: `bip39kit`
- JavaScript / React Native: `bip39-mnemonic-kit`
- Python: `bip39_mnemonic_kit`
- Rust: `bip39_mnemonic_kit`
- Dart: `bip39_mnemonic_kit`
- Kotlin: `com.devdasx.bip39mnemonickit`

When changing implementation logic:

- keep the BIP-39 English word list at exactly 2048 words;
- validate mnemonic word count, unknown words, and checksum;
- derive seeds with PBKDF2-HMAC-SHA512, 2048 iterations, 64-byte output;
- test against the official `abandon ... about` vector with passphrase `TREZOR`;
- run the relevant language tests before proposing changes.

Do not include real random mnemonics in docs, commits, or tests. Use deterministic official vectors only.
