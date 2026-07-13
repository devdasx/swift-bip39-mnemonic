import {
  entropyToMnemonic,
  generateMnemonic,
  mnemonicToSeedHex,
  validateMnemonic
} from "bip39-mnemonic-kit/react-native";

const expectedPhrase = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";
const expectedSeed = "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04";

const phrase = entropyToMnemonic("00000000000000000000000000000000");
if (phrase !== expectedPhrase) throw new Error("entropy vector failed");
if (!validateMnemonic(phrase)) throw new Error("validation failed");
if (mnemonicToSeedHex(phrase, "TREZOR") !== expectedSeed) throw new Error("seed vector failed");

const generated = generateMnemonic({
  words: 12,
  randomBytes: (count) => new Uint8Array(count)
});
if (generated !== expectedPhrase) throw new Error("injected randomBytes failed");

console.log("react-native-entrypoint-ok");
