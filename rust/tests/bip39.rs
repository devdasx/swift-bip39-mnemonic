use serde::Deserialize;
use bip39_mnemonic_kit::{
    entropy_hex_to_mnemonic, generate_mnemonic, mnemonic_to_seed_hex, validate_mnemonic,
};

#[derive(Deserialize)]
struct Vector {
    #[serde(rename = "entropyHex")]
    entropy_hex: String,
    mnemonic: String,
    #[serde(rename = "seedHex")]
    seed_hex: String,
}

#[test]
fn official_vectors() {
    let vectors: Vec<Vector> = serde_json::from_str(include_str!("english-vectors.json")).unwrap();
    for vector in vectors {
        assert_eq!(entropy_hex_to_mnemonic(&vector.entropy_hex).unwrap(), vector.mnemonic);
        assert_eq!(mnemonic_to_seed_hex(&vector.mnemonic, "TREZOR").unwrap(), vector.seed_hex);
    }
}

#[test]
fn generates_valid_mnemonics() {
    for count in [12, 15, 18, 21, 24] {
        let mnemonic = generate_mnemonic(count).unwrap();
        assert_eq!(mnemonic.split_whitespace().count(), count);
        assert!(validate_mnemonic(&mnemonic));
    }
}
