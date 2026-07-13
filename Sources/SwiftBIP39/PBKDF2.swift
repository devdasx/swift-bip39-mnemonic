import CryptoKit
import Foundation

enum PBKDF2 {
    static func deriveSHA512Key(
        password: Data,
        salt: Data,
        iterations: Int,
        keyByteCount: Int
    ) -> Data {
        precondition(iterations > 0, "PBKDF2 requires at least one iteration")
        precondition(keyByteCount > 0, "PBKDF2 requires a positive output length")

        let key = SymmetricKey(data: password)
        let hashLength = 64
        let blockCount = Int(ceil(Double(keyByteCount) / Double(hashLength)))
        var derived = Data()
        derived.reserveCapacity(blockCount * hashLength)

        for blockIndex in 1...blockCount {
            let block = salt + UInt32(blockIndex).bigEndianData
            var accumulator = Data(HMAC<SHA512>.authenticationCode(for: block, using: key))
            var current = accumulator

            if iterations > 1 {
                for _ in 2...iterations {
                    current = Data(HMAC<SHA512>.authenticationCode(for: current, using: key))
                    accumulator.xorInPlace(with: current)
                }
            }

            derived.append(accumulator)
        }

        return derived.prefix(keyByteCount)
    }
}

private extension UInt32 {
    var bigEndianData: Data {
        withUnsafeBytes(of: bigEndian) { Data($0) }
    }
}

private extension Data {
    mutating func xorInPlace(with other: Data) {
        precondition(count == other.count, "PBKDF2 XOR requires equal lengths")

        for index in indices {
            self[index] ^= other[index]
        }
    }
}
