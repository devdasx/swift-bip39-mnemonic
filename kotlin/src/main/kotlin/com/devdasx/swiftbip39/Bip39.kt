package com.devdasx.swiftbip39

import java.security.MessageDigest
import java.security.SecureRandom
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec

object Bip39 {
    private val words: List<String> = Bip39::class.java
        .getResourceAsStream("/com/devdasx/swiftbip39/english.txt")!!
        .bufferedReader()
        .readLines()

    private val indexByWord = words.withIndex().associate { it.value to it.index }
    private val validWordCounts = setOf(12, 15, 18, 21, 24)
    private val validEntropyBytes = setOf(16, 20, 24, 28, 32)

    fun generateMnemonic(words: Int = 12): String {
        val strength = wordsToStrength(words)
        val entropy = ByteArray(strength / 8)
        SecureRandom().nextBytes(entropy)
        return entropyToMnemonic(entropy)
    }

    fun entropyHexToMnemonic(hex: String): String {
        val clean = hex.removePrefix("0x")
        require(clean.length % 2 == 0) { "Invalid hex entropy" }
        return entropyToMnemonic(clean.chunked(2).map { it.toInt(16).toByte() }.toByteArray())
    }

    fun entropyToMnemonic(entropy: ByteArray): String {
        require(validEntropyBytes.contains(entropy.size)) { "Invalid entropy byte count: ${entropy.size}" }
        val entropyBits = entropy.toBits()
        val checksumLength = entropy.size * 8 / 32
        val checksumBits = sha256(entropy).toBits().substring(0, checksumLength)
        return (entropyBits + checksumBits)
            .chunked(11)
            .joinToString(" ") { words[it.toInt(2)] }
    }

    fun parseMnemonic(phrase: String): String {
        val parts = phrase.trim().split(Regex("\\s+")).filter { it.isNotEmpty() }
        require(validWordCounts.contains(parts.size)) { "Invalid word count: ${parts.size}" }
        val bits = parts.joinToString("") { word ->
            val index = indexByWord[word] ?: error("Unknown word: $word")
            index.toString(2).padStart(11, '0')
        }
        val checksumLength = bits.length / 33
        val entropyLength = bits.length - checksumLength
        val entropyBits = bits.substring(0, entropyLength)
        val checksumBits = bits.substring(entropyLength)
        val entropy = entropyBits.chunked(8).map { it.toInt(2).toByte() }.toByteArray()
        val expected = sha256(entropy).toBits().substring(0, checksumLength)
        require(checksumBits == expected) { "Invalid checksum" }
        return parts.joinToString(" ")
    }

    fun validateMnemonic(phrase: String): Boolean = runCatching { parseMnemonic(phrase) }.isSuccess

    fun mnemonicToSeed(phrase: String, passphrase: String = ""): ByteArray {
        val mnemonic = parseMnemonic(phrase)
        return pbkdf2Sha512(mnemonic.toByteArray(), "mnemonic$passphrase".toByteArray(), 2048, 64)
    }

    fun mnemonicToSeedHex(phrase: String, passphrase: String = ""): String =
        mnemonicToSeed(phrase, passphrase).joinToString("") { "%02x".format(it) }

    private fun wordsToStrength(words: Int): Int {
        require(validWordCounts.contains(words)) { "Invalid word count: $words" }
        return words / 3 * 32
    }

    private fun sha256(data: ByteArray): ByteArray = MessageDigest.getInstance("SHA-256").digest(data)

    private fun pbkdf2Sha512(password: ByteArray, salt: ByteArray, iterations: Int, keyLength: Int): ByteArray {
        val mac = Mac.getInstance("HmacSHA512")
        mac.init(SecretKeySpec(password, "HmacSHA512"))
        val hashLength = 64
        val blocks = (keyLength + hashLength - 1) / hashLength
        val out = ArrayList<Byte>(blocks * hashLength)

        for (block in 1..blocks) {
            var u = mac.doFinal(salt + byteArrayOf(
                (block ushr 24).toByte(),
                (block ushr 16).toByte(),
                (block ushr 8).toByte(),
                block.toByte()
            ))
            val t = u.copyOf()
            for (i in 2..iterations) {
                u = mac.doFinal(u)
                for (j in t.indices) t[j] = (t[j].toInt() xor u[j].toInt()).toByte()
            }
            out.addAll(t.toList())
        }

        return out.take(keyLength).toByteArray()
    }

    private fun ByteArray.toBits(): String =
        joinToString("") { (it.toInt() and 0xff).toString(2).padStart(8, '0') }
}
