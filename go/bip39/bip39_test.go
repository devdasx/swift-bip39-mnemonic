package bip39

import (
	_ "embed"
	"encoding/json"
	"strings"
	"testing"
)

//go:embed english-vectors.json
var vectorData []byte

type vector struct {
	EntropyHex string `json:"entropyHex"`
	Mnemonic   string `json:"mnemonic"`
	SeedHex    string `json:"seedHex"`
}

func TestOfficialVectors(t *testing.T) {
	var vectors []vector
	if err := json.Unmarshal(vectorData, &vectors); err != nil {
		t.Fatal(err)
	}

	for _, v := range vectors {
		mnemonic, err := EntropyHexToMnemonic(v.EntropyHex)
		if err != nil {
			t.Fatal(err)
		}
		if mnemonic != v.Mnemonic {
			t.Fatalf("mnemonic mismatch: %s", mnemonic)
		}
		seedHex, err := SeedHex(v.Mnemonic, "TREZOR")
		if err != nil {
			t.Fatal(err)
		}
		if seedHex != v.SeedHex {
			t.Fatalf("seed mismatch")
		}
	}
}

func TestGenerateValidMnemonics(t *testing.T) {
	for _, count := range []int{12, 15, 18, 21, 24} {
		mnemonic, err := Generate(count)
		if err != nil {
			t.Fatal(err)
		}
		if got := len(strings.Fields(mnemonic)); got != count {
			t.Fatalf("word count = %d, want %d", got, count)
		}
		if !Validate(mnemonic) {
			t.Fatalf("generated mnemonic did not validate")
		}
	}
}
