import Foundation

public enum BIP39Error: Error, Sendable, Equatable {
    case invalidEntropyByteCount(Int)
    case invalidWordCount(Int)
    case unknownWord(String)
    case invalidChecksum
    case randomGenerationFailed(Int)
}
