# BIP39 Mnemonic Kit examples

These examples show real install and usage flows for every supported ecosystem.

GitHub is the source of truth. Every example installs from the public GitHub release tag `2.0.1`, or from a package system that builds from that tag.

## Examples

| Folder | Ecosystem | What it demonstrates |
| --- | --- | --- |
| [`swift-spm`](swift-spm) | Swift Package Manager | Add the package to `Package.swift`, generate, validate, convert entropy, and derive seed hex. |
| [`cli`](cli) | Terminal CLI | Install `bip39kit` from GitHub Releases and run common commands. |
| [`javascript`](javascript) | Node.js / JavaScript | Install with npm from GitHub and use ESM imports. |
| [`react-native`](react-native) | React Native | Use the dedicated React Native entry point with injected secure random bytes. |
| [`python`](python) | Python | Install with pip from GitHub and use the Python import package. |
| [`rust`](rust) | Rust | Add the GitHub dependency in `Cargo.toml` and call the Rust crate. |
| [`go`](go) | Go | Install the v2 module from GitHub and import the Go subpackage. |
| [`dart-flutter`](dart-flutter) | Dart / Flutter | Add the Git dependency and import the Dart package. |
| [`kotlin`](kotlin) | Kotlin / JVM | Install with JitPack from the GitHub tag and use the Kotlin API. |

## Run all runnable examples locally

From the repository root:

```bash
examples/run-examples.sh
```

The runner copies examples into a temporary directory first, so dependency lockfiles and build outputs do not modify the repository.

The React Native folder includes a `smoke-test.mjs` that validates the React Native package entry point in Node. A real React Native app should replace the demo `secureRandomBytes` function with a production secure random provider.

## Official vector used by every example

```text
entropy: 00000000000000000000000000000000
mnemonic: abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about
passphrase: TREZOR
seed: c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04
```

Do not log or publish real wallet mnemonics. These examples use the public BIP-39 test vector only.
