from __future__ import annotations

import hashlib
import secrets
import unicodedata
from importlib import resources


class BIP39Error(ValueError):
    pass


_VALID_ENTROPY_BYTES = {16, 20, 24, 28, 32}
_VALID_WORD_COUNTS = {12, 15, 18, 21, 24}


def _wordlist() -> list[str]:
    text = resources.files(__package__).joinpath("english.txt").read_text(encoding="utf-8")
    words = text.splitlines()
    if len(words) != 2048:
        raise BIP39Error("BIP-39 English word list must contain 2048 words")
    return words


WORDS = _wordlist()
INDEX_BY_WORD = {word: index for index, word in enumerate(WORDS)}


def generate_mnemonic(words: int = 12) -> str:
    strength = _words_to_strength(words)
    return entropy_to_mnemonic(secrets.token_bytes(strength // 8))


def entropy_to_mnemonic(entropy: bytes | bytearray | str) -> str:
    if isinstance(entropy, str):
        entropy_bytes = bytes.fromhex(entropy.removeprefix("0x"))
    else:
        entropy_bytes = bytes(entropy)

    if len(entropy_bytes) not in _VALID_ENTROPY_BYTES:
        raise BIP39Error(f"Invalid entropy byte count: {len(entropy_bytes)}")

    entropy_bits = _bytes_to_bits(entropy_bytes)
    checksum_length = len(entropy_bytes) * 8 // 32
    checksum_bits = _bytes_to_bits(hashlib.sha256(entropy_bytes).digest())[:checksum_length]
    bits = entropy_bits + checksum_bits
    return " ".join(WORDS[int(bits[index:index + 11], 2)] for index in range(0, len(bits), 11))


def parse_mnemonic(phrase: str) -> str:
    words = _normalize_words(phrase)
    if len(words) not in _VALID_WORD_COUNTS:
        raise BIP39Error(f"Invalid word count: {len(words)}")

    try:
        bits = "".join(f"{INDEX_BY_WORD[word]:011b}" for word in words)
    except KeyError as error:
        raise BIP39Error(f"Unknown word: {error.args[0]}") from error

    checksum_length = len(bits) // 33
    entropy_length = len(bits) - checksum_length
    entropy_bits = bits[:entropy_length]
    checksum_bits = bits[entropy_length:]
    entropy = _bits_to_bytes(entropy_bits)
    expected = _bytes_to_bits(hashlib.sha256(entropy).digest())[:checksum_length]

    if checksum_bits != expected:
        raise BIP39Error("Invalid checksum")

    return " ".join(words)


def validate_mnemonic(phrase: str) -> bool:
    try:
        parse_mnemonic(phrase)
        return True
    except BIP39Error:
        return False


def mnemonic_to_seed(phrase: str, passphrase: str = "") -> bytes:
    mnemonic = unicodedata.normalize("NFKD", parse_mnemonic(phrase))
    salt = unicodedata.normalize("NFKD", "mnemonic" + passphrase)
    return hashlib.pbkdf2_hmac("sha512", mnemonic.encode(), salt.encode(), 2048, 64)


def mnemonic_to_seed_hex(phrase: str, passphrase: str = "") -> str:
    return mnemonic_to_seed(phrase, passphrase).hex()


def _words_to_strength(words: int) -> int:
    if words not in _VALID_WORD_COUNTS:
        raise BIP39Error(f"Invalid word count: {words}")
    return words // 3 * 32


def _normalize_words(phrase: str) -> list[str]:
    return unicodedata.normalize("NFKD", phrase).split()


def _bytes_to_bits(data: bytes) -> str:
    return "".join(f"{byte:08b}" for byte in data)


def _bits_to_bytes(bits: str) -> bytes:
    return bytes(int(bits[index:index + 8], 2) for index in range(0, len(bits), 8))
