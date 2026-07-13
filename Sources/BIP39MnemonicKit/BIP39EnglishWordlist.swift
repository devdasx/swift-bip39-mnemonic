import Foundation

enum BIP39EnglishWordlist {
    static let words: [String] = {
        let url = resourceURL()
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

    private static func resourceURL() -> URL? {
        #if SWIFT_PACKAGE
        return Bundle.module.url(forResource: "english", withExtension: "txt")
        #else
        let candidates = [
            Bundle(for: BundleLocator.self),
            Bundle.main,
        ]

        for bundle in candidates {
            if let direct = bundle.url(forResource: "english", withExtension: "txt") {
                return direct
            }

            if let resourceBundleURL = bundle.url(forResource: "BIP39MnemonicKitResources", withExtension: "bundle"),
               let resourceBundle = Bundle(url: resourceBundleURL),
               let nested = resourceBundle.url(forResource: "english", withExtension: "txt") {
                return nested
            }
        }

        return nil
        #endif
    }
}

private final class BundleLocator {}
