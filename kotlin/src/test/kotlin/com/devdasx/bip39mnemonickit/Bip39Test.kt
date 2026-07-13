package com.devdasx.bip39mnemonickit

import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import com.fasterxml.jackson.module.kotlin.readValue
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class Bip39Test {
    @Test
    fun officialVectors() {
        val json = javaClass.getResourceAsStream("/com/devdasx/bip39mnemonickit/english-vectors.json")!!
            .bufferedReader()
            .readText()
        val vectors: List<Vector> = jacksonObjectMapper().readValue(json)
        for (vector in vectors) {
            assertEquals(vector.mnemonic, Bip39.entropyHexToMnemonic(vector.entropyHex))
            assertEquals(vector.seedHex, Bip39.mnemonicToSeedHex(vector.mnemonic, "TREZOR"))
        }
    }

    @Test
    fun generatesValidMnemonics() {
        for (count in listOf(12, 15, 18, 21, 24)) {
            val mnemonic = Bip39.generateMnemonic(count)
            assertEquals(count, mnemonic.split(" ").size)
            assertTrue(Bip39.validateMnemonic(mnemonic))
        }
    }
}

data class Vector(
    val entropyHex: String,
    val mnemonic: String,
    val seedHex: String
)
