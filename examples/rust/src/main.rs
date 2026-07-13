use bip39_mnemonic_kit::{
    entropy_hex_to_mnemonic, generate_mnemonic, mnemonic_to_seed_hex, validate_mnemonic,
};

fn main() {
    let expected_phrase = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";
    let expected_seed = "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04";

    let phrase = entropy_hex_to_mnemonic("00000000000000000000000000000000").unwrap();
    assert_eq!(phrase, expected_phrase);
    assert!(validate_mnemonic(&phrase));
    assert!(!validate_mnemonic(&phrase.replace("about", "above")));

    let seed_hex = mnemonic_to_seed_hex(&phrase, "TREZOR").unwrap();
    assert_eq!(seed_hex, expected_seed);

    let generated = generate_mnemonic(12).unwrap();
    assert_eq!(generated.split_whitespace().count(), 12);

    println!("mnemonic: {phrase}");
    println!("seed prefix: {}", &seed_hex[..16]);
    println!("generated words: {}", generated.split_whitespace().count());
}
