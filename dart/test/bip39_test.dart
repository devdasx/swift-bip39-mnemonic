import 'dart:convert';
import 'dart:io';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:test/test.dart';

void main() {
  test('matches official English vectors', () {
    final vectors = jsonDecode(File('dart/test/english-vectors.json').readAsStringSync()) as List<dynamic>;
    for (final vector in vectors.cast<Map<String, dynamic>>()) {
      expect(entropyHexToMnemonic(vector['entropyHex'] as String), vector['mnemonic']);
      expect(parseMnemonic(vector['mnemonic'] as String), vector['mnemonic']);
      expect(mnemonicToSeedHex(vector['mnemonic'] as String, passphrase: 'TREZOR'), vector['seedHex']);
    }
  });

  test('generates valid mnemonics', () {
    for (final count in [12, 15, 18, 21, 24]) {
      final mnemonic = generateMnemonic(words: count);
      expect(mnemonic.split(' '), hasLength(count));
      expect(validateMnemonic(mnemonic), isTrue);
    }
  });
}
