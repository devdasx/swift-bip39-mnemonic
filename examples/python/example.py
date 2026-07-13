from bip39_mnemonic_kit import (
    entropy_to_mnemonic,
    generate_mnemonic,
    mnemonic_to_seed_hex,
    validate_mnemonic,
)

EXPECTED_PHRASE = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
EXPECTED_SEED = "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04"

phrase = entropy_to_mnemonic("00000000000000000000000000000000")
assert phrase == EXPECTED_PHRASE
assert validate_mnemonic(phrase)
assert not validate_mnemonic(phrase.replace("about", "above"))

seed_hex = mnemonic_to_seed_hex(phrase, "TREZOR")
assert seed_hex == EXPECTED_SEED

generated = generate_mnemonic(words=12)
assert len(generated.split()) == 12

print("mnemonic:", phrase)
print("seed prefix:", seed_hex[:16])
print("generated words:", len(generated.split()))
