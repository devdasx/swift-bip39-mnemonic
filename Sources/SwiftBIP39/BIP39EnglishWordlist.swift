import Foundation

enum BIP39EnglishWordlist {
    static let words: [String] = {
        let url = Bundle.module.url(forResource: "english", withExtension: "txt")
        precondition(url != nil, "Missing BIP-39 English word list resource")

        let contents = try? String(contentsOf: url!, encoding: .utf8)
        precondition(contents != nil, "Unable to read BIP-39 English word list resource")

        let words = contents!
            .split(whereSeparator: \.isNewline)
            .map(String.init)

        precondition(words.count == 2048, "BIP-39 English word list must contain exactly 2048 words")
        return words
    }()

    static let indexByWord: [String: Int] = {
        Dictionary(uniqueKeysWithValues: words.enumerated().map { ($0.element, $0.offset) })
    }()
}
