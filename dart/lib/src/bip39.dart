import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'wordlist.dart';

class Bip39Exception implements Exception {
  const Bip39Exception(this.message);
  final String message;

  @override
  String toString() => 'Bip39Exception: $message';
}

final _indexByWord = {
  for (var i = 0; i < englishWords.length; i++) englishWords[i]: i,
};

String generateMnemonic({int words = 12}) {
  final strength = _wordsToStrength(words);
  final random = Random.secure();
  final entropy = Uint8List.fromList(List.generate(strength ~/ 8, (_) => random.nextInt(256)));
  return entropyToMnemonic(entropy);
}

String entropyHexToMnemonic(String hex) {
  final clean = hex.startsWith('0x') ? hex.substring(2) : hex;
  if (clean.length.isOdd) throw const Bip39Exception('Invalid hex entropy');
  final bytes = <int>[];
  for (var i = 0; i < clean.length; i += 2) {
    bytes.add(int.parse(clean.substring(i, i + 2), radix: 16));
  }
  return entropyToMnemonic(Uint8List.fromList(bytes));
}

String entropyToMnemonic(Uint8List entropy) {
  if (!_validEntropyBytes(entropy.length)) {
    throw Bip39Exception('Invalid entropy byte count: ${entropy.length}');
  }
  final entropyBits = _bytesToBits(entropy);
  final checksumLength = entropy.length * 8 ~/ 32;
  final checksumBits = _bytesToBits(Uint8List.fromList(sha256.convert(entropy).bytes)).substring(0, checksumLength);
  final bits = entropyBits + checksumBits;
  final words = <String>[];
  for (var i = 0; i < bits.length; i += 11) {
    words.add(englishWords[int.parse(bits.substring(i, i + 11), radix: 2)]);
  }
  return words.join(' ');
}

String parseMnemonic(String phrase) {
  final words = phrase.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
  if (!_validWordCount(words.length)) {
    throw Bip39Exception('Invalid word count: ${words.length}');
  }
  final bits = StringBuffer();
  for (final word in words) {
    final index = _indexByWord[word];
    if (index == null) throw Bip39Exception('Unknown word: $word');
    bits.write(index.toRadixString(2).padLeft(11, '0'));
  }

  final allBits = bits.toString();
  final checksumLength = allBits.length ~/ 33;
  final entropyLength = allBits.length - checksumLength;
  final entropyBits = allBits.substring(0, entropyLength);
  final checksumBits = allBits.substring(entropyLength);
  final entropy = _bitsToBytes(entropyBits);
  final expected = _bytesToBits(Uint8List.fromList(sha256.convert(entropy).bytes)).substring(0, checksumLength);
  if (checksumBits != expected) throw const Bip39Exception('Invalid checksum');
  return words.join(' ');
}

bool validateMnemonic(String phrase) {
  try {
    parseMnemonic(phrase);
    return true;
  } catch (_) {
    return false;
  }
}

Uint8List mnemonicToSeed(String phrase, {String passphrase = ''}) {
  final mnemonic = utf8.encode(parseMnemonic(phrase));
  final salt = utf8.encode('mnemonic$passphrase');
  return _pbkdf2Sha512(mnemonic, salt, 2048, 64);
}

String mnemonicToSeedHex(String phrase, {String passphrase = ''}) {
  return mnemonicToSeed(phrase, passphrase: passphrase).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

int _wordsToStrength(int words) {
  if (!_validWordCount(words)) throw Bip39Exception('Invalid word count: $words');
  return words ~/ 3 * 32;
}

bool _validEntropyBytes(int count) => const {16, 20, 24, 28, 32}.contains(count);
bool _validWordCount(int count) => const {12, 15, 18, 21, 24}.contains(count);

String _bytesToBits(Uint8List bytes) => bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join();

Uint8List _bitsToBytes(String bits) {
  final out = <int>[];
  for (var i = 0; i < bits.length; i += 8) {
    out.add(int.parse(bits.substring(i, i + 8), radix: 2));
  }
  return Uint8List.fromList(out);
}

Uint8List _pbkdf2Sha512(List<int> password, List<int> salt, int iterations, int keyLength) {
  const hashLength = 64;
  final blocks = (keyLength / hashLength).ceil();
  final out = <int>[];
  final hmac = Hmac(sha512, password);

  for (var block = 1; block <= blocks; block++) {
    final blockBytes = ByteData(4)..setUint32(0, block, Endian.big);
    var u = hmac.convert([...salt, ...blockBytes.buffer.asUint8List()]).bytes;
    final t = List<int>.from(u);
    for (var i = 2; i <= iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < t.length; j++) {
        t[j] ^= u[j];
      }
    }
    out.addAll(t);
  }

  return Uint8List.fromList(out.take(keyLength).toList());
}
