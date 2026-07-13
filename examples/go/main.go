package main

import (
	"fmt"
	"strings"

	"github.com/devdasx/bip39-mnemonic-kit/v2/go/bip39"
)

func main() {
	expectedPhrase := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	expectedSeed := "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04"

	phrase, err := bip39.EntropyHexToMnemonic("00000000000000000000000000000000")
	must(err)
	if phrase != expectedPhrase {
		panic("entropy vector failed")
	}
	if !bip39.Validate(phrase) {
		panic("validation failed")
	}
	if bip39.Validate(strings.Replace(phrase, "about", "above", 1)) {
		panic("bad checksum accepted")
	}

	seedHex, err := bip39.SeedHex(phrase, "TREZOR")
	must(err)
	if seedHex != expectedSeed {
		panic("seed vector failed")
	}

	generated, err := bip39.Generate(12)
	must(err)
	if len(strings.Fields(generated)) != 12 {
		panic("generation failed")
	}

	fmt.Println("mnemonic:", phrase)
	fmt.Println("seed prefix:", seedHex[:16])
	fmt.Println("generated words:", len(strings.Fields(generated)))
}

func must(err error) {
	if err != nil {
		panic(err)
	}
}
