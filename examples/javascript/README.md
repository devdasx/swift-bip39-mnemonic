# JavaScript / Node.js example

This example installs `bip39-mnemonic-kit` from GitHub and uses the ESM JavaScript API.

## Install

```bash
npm install github:devdasx/bip39-mnemonic-kit#2.0.1
```

When the npm registry package is published, the registry install command is:

```bash
npm install bip39-mnemonic-kit
```

## Run

```bash
npm install
node example.mjs
```

## What it does

- Imports from `bip39-mnemonic-kit`.
- Converts entropy hex into a mnemonic.
- Validates the mnemonic checksum.
- Derives a seed hex.
- Generates a new 12-word mnemonic.
