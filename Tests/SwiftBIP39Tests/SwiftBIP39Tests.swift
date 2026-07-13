import Foundation
import Testing
@testable import SwiftBIP39

@Test func matchesAllOfficialEnglishBIP39Vectors() throws {
    let vectors = try loadEnglishVectors()

    for vector in vectors {
        let entropy = try #require(Data(hex: vector.entropyHex))
        let mnemonic = try BIP39.mnemonic(from: entropy)
        #expect(mnemonic.phrase == vector.mnemonic)

        let parsed = try BIP39.parse(vector.mnemonic)
        #expect(parsed.phrase == vector.mnemonic)

        let seed = BIP39.seed(from: parsed, passphrase: "TREZOR")
        #expect(seed.hexEncodedString == vector.seedHex)
    }
}

@Test func rejectsMnemonicWithBadChecksum() {
    let invalidPhrase = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon"

    #expect(!BIP39.validate(invalidPhrase))
    #expect(throws: BIP39Error.invalidChecksum) {
        try BIP39.parse(invalidPhrase)
    }
}

@Test func rejectsUnknownWords() {
    let invalidPhrase = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon codex"

    #expect(!BIP39.validate(invalidPhrase))
    #expect(throws: BIP39Error.unknownWord("codex")) {
        try BIP39.parse(invalidPhrase)
    }
}

@Test func generatesConfiguredWordCounts() throws {
    let strengths: [BIP39.EntropyStrength] = [.bits128, .bits160, .bits192, .bits224, .bits256]
    let expected = [12, 15, 18, 21, 24]

    for (strength, count) in zip(strengths, expected) {
        let mnemonic = try BIP39.generate(strength: strength)
        #expect(mnemonic.words.count == count)
        #expect(BIP39.validate(mnemonic.phrase))
    }
}

@Test func generatesValidMnemonicsRepeatedly() throws {
    for _ in 0..<250 {
        let mnemonic = try BIP39.generate(strength: .bits128)
        #expect(mnemonic.words.count == 12)
        #expect(BIP39.validate(mnemonic.phrase))
    }
}

@Test func rejectsUnsupportedEntropySizes() throws {
    let invalidEntropy = Data(repeating: 0, count: 17)

    #expect(throws: BIP39Error.invalidEntropyByteCount(17)) {
        try BIP39.mnemonic(from: invalidEntropy)
    }
}

private struct EnglishVector: Codable {
    let entropyHex: String
    let mnemonic: String
    let seedHex: String
}

private func loadEnglishVectors() throws -> [EnglishVector] {
    let url = try #require(Bundle.module.url(forResource: "english-vectors", withExtension: "json"))
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode([EnglishVector].self, from: data)
}

private extension Data {
    init?(hex: String) {
        guard hex.count.isMultiple(of: 2) else { return nil }

        var data = Data()
        data.reserveCapacity(hex.count / 2)

        var index = hex.startIndex
        while index < hex.endIndex {
            let nextIndex = hex.index(index, offsetBy: 2)
            let byteString = hex[index..<nextIndex]
            guard let byte = UInt8(byteString, radix: 16) else { return nil }
            data.append(byte)
            index = nextIndex
        }

        self = data
    }

    var hexEncodedString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
