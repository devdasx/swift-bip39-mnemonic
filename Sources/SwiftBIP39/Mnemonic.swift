import Foundation

public struct Mnemonic: Sendable, Equatable, Hashable, Codable, CustomStringConvertible {
    public let words: [String]

    public init(words: [String]) {
        self.words = words
    }

    public init(validating phrase: String) throws {
        self = try BIP39.parse(phrase)
    }

    public var phrase: String {
        words.joined(separator: " ")
    }

    public var description: String {
        phrase
    }
}
