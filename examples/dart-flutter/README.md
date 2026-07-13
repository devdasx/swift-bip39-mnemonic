# Dart / Flutter example

This example uses the Dart package API. The same package can be imported from Flutter apps.

## Install

Add a Git dependency:

```yaml
dependencies:
  bip39_mnemonic_kit:
    git:
      url: https://github.com/devdasx/bip39-mnemonic-kit.git
      ref: 2.0.1
```

When the pub.dev package is published:

```yaml
dependencies:
  bip39_mnemonic_kit: ^2.0.1
```

## Run

```bash
dart pub get
dart run bin/main.dart
```

In Flutter, use the same import:

```dart
import 'package:bip39_mnemonic_kit/bip39_mnemonic_kit.dart';
```
