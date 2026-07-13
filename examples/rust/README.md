# Rust example

This example installs the Rust crate from the GitHub tag.

## Install

Add this dependency:

```toml
[dependencies]
bip39-mnemonic-kit = { git = "https://github.com/devdasx/bip39-mnemonic-kit.git", tag = "2.0.1" }
```

When the crates.io package is published:

```bash
cargo add bip39-mnemonic-kit
```

## Run

```bash
cargo run --release
```
