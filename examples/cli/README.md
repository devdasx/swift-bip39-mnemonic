# CLI example

This example installs the `bip39kit` command from GitHub Releases and runs common terminal commands.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/devdasx/bip39-mnemonic-kit/main/install.sh | sh
```

Or install from Homebrew:

```bash
brew tap devdasx/tap
brew install bip39kit
```

## Run this example

```bash
sh run.sh
```

`run.sh` installs version `2.0.1` into a temporary local prefix unless `BIP39KIT_BIN` is set.

## Commands shown

```bash
bip39kit version
bip39kit entropy-to-mnemonic 00000000000000000000000000000000
bip39kit validate "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
bip39kit seed "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about" --passphrase TREZOR
bip39kit generate --words 12
```
