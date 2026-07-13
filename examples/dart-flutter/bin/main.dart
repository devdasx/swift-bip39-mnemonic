import 'package:bip39_mnemonic_kit/bip39_mnemonic_kit.dart';

void check(bool condition, String label) {
  if (!condition) throw StateError(label);
}

void main() {
  const expectedPhrase = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
  const expectedSeed = 'c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04';

  final phrase = entropyHexToMnemonic('00000000000000000000000000000000');
  check(phrase == expectedPhrase, 'entropy vector failed');
  check(validateMnemonic(phrase), 'validation failed');
  check(!validateMnemonic(phrase.replaceFirst('about', 'above')), 'bad checksum accepted');

  final seedHex = mnemonicToSeedHex(phrase, passphrase: 'TREZOR');
  check(seedHex == expectedSeed, 'seed vector failed');

  final generated = generateMnemonic(words: 12);
  check(generated.split(RegExp(r'\s+')).length == 12, 'generation failed');

  print('mnemonic: $phrase');
  print('seed prefix: ${seedHex.substring(0, 16)}');
  print('generated words: ${generated.split(RegExp(r'\s+')).length}');
}
