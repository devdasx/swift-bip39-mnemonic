use hmac::Hmac;
use pbkdf2::pbkdf2;
use rand::RngCore;
use sha2::{Digest, Sha256, Sha512};
use std::collections::HashMap;
use std::sync::OnceLock;

type HmacSha512 = Hmac<Sha512>;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Bip39Error {
    InvalidEntropyByteCount(usize),
    InvalidWordCount(usize),
    UnknownWord(String),
    InvalidChecksum,
    InvalidHex,
}

static WORDS: OnceLock<Vec<&'static str>> = OnceLock::new();
static INDEX_BY_WORD: OnceLock<HashMap<&'static str, usize>> = OnceLock::new();

pub fn generate_mnemonic(words: usize) -> Result<String, Bip39Error> {
    let strength = words_to_strength(words)?;
    let mut entropy = vec![0u8; strength / 8];
    rand::thread_rng().fill_bytes(&mut entropy);
    entropy_to_mnemonic(&entropy)
}

pub fn entropy_hex_to_mnemonic(hex: &str) -> Result<String, Bip39Error> {
    entropy_to_mnemonic(&decode_hex(hex)?)
}

pub fn entropy_to_mnemonic(entropy: &[u8]) -> Result<String, Bip39Error> {
    if !valid_entropy_bytes(entropy.len()) {
        return Err(Bip39Error::InvalidEntropyByteCount(entropy.len()));
    }

    let checksum = Sha256::digest(entropy);
    let checksum_bits = entropy.len() * 8 / 32;
    let total_bits = entropy.len() * 8 + checksum_bits;
    let words = words();
    let mut out = Vec::with_capacity(total_bits / 11);

    for word_index in 0..total_bits / 11 {
        let mut index = 0usize;
        for offset in 0..11 {
            let bit_index = word_index * 11 + offset;
            let bit = if bit_index < entropy.len() * 8 {
                bit_at(entropy, bit_index)
            } else {
                bit_at(&checksum, bit_index - entropy.len() * 8)
            };
            index = (index << 1) | bit;
        }
        out.push(words[index]);
    }

    Ok(out.join(" "))
}

pub fn parse_mnemonic(phrase: &str) -> Result<String, Bip39Error> {
    let parts: Vec<&str> = phrase.split_whitespace().collect();
    if !valid_word_count(parts.len()) {
        return Err(Bip39Error::InvalidWordCount(parts.len()));
    }

    let total_bits = parts.len() * 11;
    let checksum_bits = total_bits / 33;
    let entropy_bits = total_bits - checksum_bits;
    let mut entropy = vec![0u8; entropy_bits / 8];

    for bit_index in 0..entropy_bits {
        let bit = phrase_bit(&parts, bit_index)?;
        set_bit(&mut entropy, bit_index, bit);
    }

    let checksum = Sha256::digest(&entropy);
    for offset in 0..checksum_bits {
        let expected = bit_at(&checksum, offset);
        let actual = phrase_bit(&parts, entropy_bits + offset)?;
        if expected != actual {
            return Err(Bip39Error::InvalidChecksum);
        }
    }

    Ok(parts.join(" "))
}

pub fn validate_mnemonic(phrase: &str) -> bool {
    parse_mnemonic(phrase).is_ok()
}

pub fn mnemonic_to_seed(phrase: &str, passphrase: &str) -> Result<[u8; 64], Bip39Error> {
    let mnemonic = parse_mnemonic(phrase)?;
    let salt = format!("mnemonic{}", passphrase);
    let mut seed = [0u8; 64];
    pbkdf2::<HmacSha512>(mnemonic.as_bytes(), salt.as_bytes(), 2048, &mut seed)
        .expect("HMAC can accept any key length");
    Ok(seed)
}

pub fn mnemonic_to_seed_hex(phrase: &str, passphrase: &str) -> Result<String, Bip39Error> {
    Ok(encode_hex(&mnemonic_to_seed(phrase, passphrase)?))
}

fn words() -> &'static [&'static str] {
    WORDS
        .get_or_init(|| include_str!("english.txt").lines().collect())
        .as_slice()
}

fn index_by_word() -> &'static HashMap<&'static str, usize> {
    INDEX_BY_WORD.get_or_init(|| words().iter().enumerate().map(|(i, word)| (*word, i)).collect())
}

fn phrase_bit(parts: &[&str], bit_index: usize) -> Result<usize, Bip39Error> {
    let word_index = bit_index / 11;
    let offset = bit_index % 11;
    let index = index_by_word()
        .get(parts[word_index])
        .ok_or_else(|| Bip39Error::UnknownWord(parts[word_index].to_string()))?;
    Ok((index >> (10 - offset)) & 1)
}

fn valid_entropy_bytes(count: usize) -> bool {
    matches!(count, 16 | 20 | 24 | 28 | 32)
}

fn valid_word_count(count: usize) -> bool {
    matches!(count, 12 | 15 | 18 | 21 | 24)
}

fn words_to_strength(count: usize) -> Result<usize, Bip39Error> {
    if !valid_word_count(count) {
        return Err(Bip39Error::InvalidWordCount(count));
    }
    Ok(count / 3 * 32)
}

fn bit_at(data: &[u8], bit_index: usize) -> usize {
    ((data[bit_index / 8] >> (7 - bit_index % 8)) & 1) as usize
}

fn set_bit(data: &mut [u8], bit_index: usize, value: usize) {
    if value == 1 {
        data[bit_index / 8] |= 1 << (7 - bit_index % 8);
    }
}

fn decode_hex(value: &str) -> Result<Vec<u8>, Bip39Error> {
    let hex = value.strip_prefix("0x").unwrap_or(value);
    if hex.len() % 2 != 0 {
        return Err(Bip39Error::InvalidHex);
    }
    (0..hex.len())
        .step_by(2)
        .map(|i| u8::from_str_radix(&hex[i..i + 2], 16).map_err(|_| Bip39Error::InvalidHex))
        .collect()
}

fn encode_hex(bytes: &[u8]) -> String {
    bytes.iter().map(|byte| format!("{:02x}", byte)).collect()
}
