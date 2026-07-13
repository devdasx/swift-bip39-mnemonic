import CryptoKit
import Foundation
import Security

public enum BIP39 {
    public enum EntropyStrength: Int, CaseIterable, Sendable {
        case bits128 = 128
        case bits160 = 160
        case bits192 = 192
        case bits224 = 224
        case bits256 = 256

        public var byteCount: Int {
            rawValue / 8
        }

        public var wordCount: Int {
            rawValue / 32 * 3
        }
    }

    public static func generate(strength: EntropyStrength = .bits128) throws -> Mnemonic {
        let entropy = try secureRandomBytes(count: strength.byteCount)
        return try mnemonic(from: entropy)
    }

    public static func mnemonic(from entropy: Data) throws -> Mnemonic {
        guard Self.isValidEntropyByteCount(entropy.count) else {
            throw BIP39Error.invalidEntropyByteCount(entropy.count)
        }

        let checksum = Data(SHA256.hash(data: entropy))
        let checksumBitCount = entropy.count * 8 / 32
        let totalBitCount = entropy.count * 8 + checksumBitCount
        let wordCount = totalBitCount / 11

        var words: [String] = []
        words.reserveCapacity(wordCount)

        for wordIndex in 0..<wordCount {
            var listIndex = 0

            for offset in 0..<11 {
                let bitIndex = wordIndex * 11 + offset
                let bit = bitIndex < entropy.count * 8
                    ? entropy.bit(at: bitIndex)
                    : checksum.bit(at: bitIndex - entropy.count * 8)

                listIndex = (listIndex << 1) | bit
            }

            words.append(BIP39EnglishWordlist.words[listIndex])
        }

        return Mnemonic(words: words)
    }

    public static func parse(_ phrase: String) throws -> Mnemonic {
        let normalizedWords = normalizedWords(from: phrase)

        guard [12, 15, 18, 21, 24].contains(normalizedWords.count) else {
            throw BIP39Error.invalidWordCount(normalizedWords.count)
        }

        for word in normalizedWords where BIP39EnglishWordlist.indexByWord[word] == nil {
            throw BIP39Error.unknownWord(word)
        }

        let indices = normalizedWords.map { BIP39EnglishWordlist.indexByWord[$0]! }
        let totalBitCount = indices.count * 11
        let checksumBitCount = totalBitCount / 33
        let entropyBitCount = totalBitCount - checksumBitCount
        let entropyByteCount = entropyBitCount / 8
        var entropy = Data(repeating: 0, count: entropyByteCount)

        for bitIndex in 0..<entropyBitCount {
            let value = bit(from: indices, at: bitIndex)
            entropy.setBit(value, at: bitIndex)
        }

        let checksum = Data(SHA256.hash(data: entropy))
        for checksumOffset in 0..<checksumBitCount {
            let expected = checksum.bit(at: checksumOffset)
            let actual = bit(from: indices, at: entropyBitCount + checksumOffset)
            guard expected == actual else {
                throw BIP39Error.invalidChecksum
            }
        }

        return Mnemonic(words: normalizedWords)
    }

    public static func validate(_ phrase: String) -> Bool {
        (try? parse(phrase)) != nil
    }

    public static func seed(from phrase: String, passphrase: String = "") throws -> Data {
        let mnemonic = try parse(phrase)
        return seed(from: mnemonic, passphrase: passphrase)
    }

    public static func seed(from mnemonic: Mnemonic, passphrase: String = "") -> Data {
        let normalizedMnemonic = mnemonic.phrase.decomposedStringWithCompatibilityMapping
        let normalizedPassphrase = passphrase.decomposedStringWithCompatibilityMapping
        let password = Data(normalizedMnemonic.utf8)
        let salt = Data(("mnemonic" + normalizedPassphrase).utf8)

        return PBKDF2.deriveSHA512Key(
            password: password,
            salt: salt,
            iterations: 2048,
            keyByteCount: 64
        )
    }

    private static func normalizedWords(from phrase: String) -> [String] {
        phrase
            .decomposedStringWithCompatibilityMapping
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)
    }

    private static func isValidEntropyByteCount(_ count: Int) -> Bool {
        [16, 20, 24, 28, 32].contains(count)
    }

    private static func bit(from indices: [Int], at bitIndex: Int) -> Int {
        let wordIndex = bitIndex / 11
        let offset = bitIndex % 11
        let shift = 10 - offset
        return (indices[wordIndex] >> shift) & 1
    }

    private static func secureRandomBytes(count: Int) throws -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)

        guard status == errSecSuccess else {
            throw BIP39Error.randomGenerationFailed(Int(status))
        }

        return Data(bytes)
    }
}

private extension Data {
    func bit(at bitIndex: Int) -> Int {
        let byteIndex = bitIndex / 8
        let shift = 7 - (bitIndex % 8)
        return Int((self[byteIndex] >> shift) & 1)
    }

    mutating func setBit(_ value: Int, at bitIndex: Int) {
        guard value == 1 else { return }

        let byteIndex = bitIndex / 8
        let shift = 7 - (bitIndex % 8)
        self[byteIndex] |= UInt8(1 << shift)
    }
}
