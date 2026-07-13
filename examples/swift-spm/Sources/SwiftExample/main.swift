import BIP39MnemonicKit
import Foundation

let expectedPhrase = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
let expectedSeed = "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04"

let entropy = Data(repeating: 0, count: 16)
let phrase = try BIP39.mnemonic(from: entropy).phrase
precondition(phrase == expectedPhrase)
precondition(BIP39.validate(phrase))
precondition(!BIP39.validate(phrase.replacingOccurrences(of: "about", with: "above")))

let seedHex = try BIP39.seed(from: phrase, passphrase: "TREZOR").hexEncodedString
precondition(seedHex == expectedSeed)

let generated = try BIP39.generate(strength: .bits128)
precondition(generated.words.count == 12)

print("mnemonic:", phrase)
print("seed prefix:", seedHex.prefix(16))
print("generated words:", generated.words.count)

private extension Data {
    var hexEncodedString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
