import com.devdasx.bip39mnemonickit.Bip39

fun check(condition: Boolean, label: String) {
    if (!condition) error(label)
}

fun main() {
    val expectedPhrase = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
    val expectedSeed = "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04"

    val phrase = Bip39.entropyHexToMnemonic("00000000000000000000000000000000")
    check(phrase == expectedPhrase, "entropy vector failed")
    check(Bip39.validateMnemonic(phrase), "validation failed")
    check(!Bip39.validateMnemonic(phrase.replaceFirst("about", "above")), "bad checksum accepted")

    val seedHex = Bip39.mnemonicToSeedHex(phrase, "TREZOR")
    check(seedHex == expectedSeed, "seed vector failed")

    val generated = Bip39.generateMnemonic(12)
    check(generated.split(Regex("\\s+")).size == 12, "generation failed")

    println("mnemonic: $phrase")
    println("seed prefix: ${seedHex.take(16)}")
    println("generated words: ${generated.split(Regex("\\s+")).size}")
}
