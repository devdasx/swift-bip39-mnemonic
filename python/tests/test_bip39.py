import json
import pathlib
import unittest

from swiftbip39 import (
    entropy_to_mnemonic,
    generate_mnemonic,
    mnemonic_to_seed_hex,
    parse_mnemonic,
    validate_mnemonic,
)


class BIP39Tests(unittest.TestCase):
    def test_official_vectors(self):
        vectors = json.loads(pathlib.Path(__file__).with_name("english-vectors.json").read_text())
        for vector in vectors:
            self.assertEqual(entropy_to_mnemonic(vector["entropyHex"]), vector["mnemonic"])
            self.assertEqual(parse_mnemonic(vector["mnemonic"]), vector["mnemonic"])
            self.assertEqual(mnemonic_to_seed_hex(vector["mnemonic"], "TREZOR"), vector["seedHex"])

    def test_generate_valid_mnemonics(self):
        for words in (12, 15, 18, 21, 24):
            mnemonic = generate_mnemonic(words)
            self.assertEqual(len(mnemonic.split()), words)
            self.assertTrue(validate_mnemonic(mnemonic))

    def test_invalid_checksum(self):
        self.assertFalse(validate_mnemonic("abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon"))


if __name__ == "__main__":
    unittest.main()
