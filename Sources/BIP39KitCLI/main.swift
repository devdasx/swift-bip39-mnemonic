import Foundation
import BIP39MnemonicKit

private let version = "1.1.0"

enum CLIError: Error, CustomStringConvertible {
    case invalidCommand(String)
    case missingValue(String)
    case invalidValue(String)

    var description: String {
        switch self {
        case .invalidCommand(let command):
            return "Invalid command: \(command)"
        case .missingValue(let option):
            return "Missing value for \(option)"
        case .invalidValue(let value):
            return "Invalid value: \(value)"
        }
    }
}

func main(_ arguments: [String]) throws {
    var args = Array(arguments.dropFirst())
    guard let command = args.first else {
        printUsage()
        return
    }
    args.removeFirst()

    switch command {
    case "generate":
        let strength = try parseStrength(from: args)
        print(try BIP39.generate(strength: strength).phrase)
    case "validate":
        let phrase = try phrase(from: args)
        print(BIP39.validate(phrase) ? "valid" : "invalid")
    case "seed":
        let phrase = try phrase(from: args)
        let passphrase = value(after: "--passphrase", in: args) ?? ""
        print(try BIP39.seed(from: phrase, passphrase: passphrase).hexEncodedString)
    case "entropy-to-mnemonic":
        guard let hex = args.first else { throw CLIError.missingValue("entropy hex") }
        guard let entropy = Data(hex: hex) else { throw CLIError.invalidValue(hex) }
        print(try BIP39.mnemonic(from: entropy).phrase)
    case "version", "--version", "-v":
        print(version)
    case "help", "--help", "-h":
        printUsage()
    default:
        throw CLIError.invalidCommand(command)
    }
}

func phrase(from args: [String]) throws -> String {
    var positional: [String] = []
    var index = 0
    while index < args.count {
        let value = args[index]
        if value == "--passphrase" {
            index += 2
            continue
        }
        if value.hasPrefix("--") {
            index += 1
            continue
        }
        positional.append(value)
        index += 1
    }
    guard !positional.isEmpty else { throw CLIError.missingValue("mnemonic phrase") }
    return positional.joined(separator: " ")
}

func parseStrength(from args: [String]) throws -> BIP39.EntropyStrength {
    if let wordsValue = value(after: "--words", in: args) {
        switch wordsValue {
        case "12": return .bits128
        case "15": return .bits160
        case "18": return .bits192
        case "21": return .bits224
        case "24": return .bits256
        default: throw CLIError.invalidValue(wordsValue)
        }
    }

    if let strengthValue = value(after: "--strength", in: args) {
        guard let bits = Int(strengthValue),
              let strength = BIP39.EntropyStrength(rawValue: bits) else {
            throw CLIError.invalidValue(strengthValue)
        }
        return strength
    }

    return .bits128
}

func value(after option: String, in args: [String]) -> String? {
    guard let index = args.firstIndex(of: option) else { return nil }
    let nextIndex = args.index(after: index)
    guard nextIndex < args.endIndex else { return nil }
    return args[nextIndex]
}

func printUsage() {
    print("""
    bip39kit \(version)

    Usage:
      bip39kit generate [--words 12|15|18|21|24]
      bip39kit generate [--strength 128|160|192|224|256]
      bip39kit validate "<mnemonic phrase>"
      bip39kit seed "<mnemonic phrase>" [--passphrase value]
      bip39kit entropy-to-mnemonic <hex>
      bip39kit version
    """)
}

do {
    try main(CommandLine.arguments)
} catch {
    fputs("error: \(error)\n", stderr)
    exit(1)
}

private extension Data {
    init?(hex: String) {
        guard hex.count.isMultiple(of: 2) else { return nil }
        var data = Data()
        data.reserveCapacity(hex.count / 2)

        var index = hex.startIndex
        while index < hex.endIndex {
            let next = hex.index(index, offsetBy: 2)
            guard let byte = UInt8(hex[index..<next], radix: 16) else { return nil }
            data.append(byte)
            index = next
        }

        self = data
    }

    var hexEncodedString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
