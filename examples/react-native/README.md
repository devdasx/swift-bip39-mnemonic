# React Native example

React Native uses the same npm package with the dedicated entry point:

```js
import { generateMnemonic, validateMnemonic } from "bip39-mnemonic-kit/react-native";
```

The React Native build requires you to inject a secure random byte provider because React Native runtimes differ by app and platform.

## Install

```bash
npm install github:devdasx/bip39-mnemonic-kit#2.0.1
```

When the npm registry package is published:

```bash
npm install bip39-mnemonic-kit
```

## App usage

See [`App.tsx`](App.tsx) for a minimal component.

Replace the demo `secureRandomBytes` with a production secure random implementation from your app’s crypto provider.

## Smoke test the entry point

```bash
npm install
node smoke-test.mjs
```
