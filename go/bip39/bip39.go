package bip39

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"crypto/sha512"
	"embed"
	"encoding/binary"
	"encoding/hex"
	"errors"
	"fmt"
	"strings"
)

//go:embed english.txt
var files embed.FS

var (
	words       []string
	indexByWord map[string]int
)

func init() {
	data, err := files.ReadFile("english.txt")
	if err != nil {
		panic(err)
	}
	words = strings.Fields(string(data))
	if len(words) != 2048 {
		panic("BIP-39 English word list must contain 2048 words")
	}
	indexByWord = make(map[string]int, len(words))
	for i, word := range words {
		indexByWord[word] = i
	}
}

func Generate(wordsCount int) (string, error) {
	strength, err := wordsToStrength(wordsCount)
	if err != nil {
		return "", err
	}
	entropy := make([]byte, strength/8)
	if _, err := rand.Read(entropy); err != nil {
		return "", err
	}
	return EntropyToMnemonic(entropy)
}

func EntropyHexToMnemonic(value string) (string, error) {
	entropy, err := hex.DecodeString(strings.TrimPrefix(value, "0x"))
	if err != nil {
		return "", err
	}
	return EntropyToMnemonic(entropy)
}

func EntropyToMnemonic(entropy []byte) (string, error) {
	if !validEntropyBytes(len(entropy)) {
		return "", fmt.Errorf("invalid entropy byte count: %d", len(entropy))
	}
	checksum := sha256.Sum256(entropy)
	checksumBits := len(entropy) * 8 / 32
	totalBits := len(entropy)*8 + checksumBits
	out := make([]string, 0, totalBits/11)

	for wordIndex := 0; wordIndex < totalBits/11; wordIndex++ {
		index := 0
		for offset := 0; offset < 11; offset++ {
			bitIndex := wordIndex*11 + offset
			var bit int
			if bitIndex < len(entropy)*8 {
				bit = bitAt(entropy, bitIndex)
			} else {
				bit = bitAt(checksum[:], bitIndex-len(entropy)*8)
			}
			index = (index << 1) | bit
		}
		out = append(out, words[index])
	}

	return strings.Join(out, " "), nil
}

func Parse(phrase string) (string, error) {
	parts := strings.Fields(phrase)
	if !validWordCount(len(parts)) {
		return "", fmt.Errorf("invalid word count: %d", len(parts))
	}

	totalBits := len(parts) * 11
	checksumBits := totalBits / 33
	entropyBits := totalBits - checksumBits
	entropy := make([]byte, entropyBits/8)

	for bitIndex := 0; bitIndex < entropyBits; bitIndex++ {
		bit, err := phraseBit(parts, bitIndex)
		if err != nil {
			return "", err
		}
		setBit(entropy, bitIndex, bit)
	}

	checksum := sha256.Sum256(entropy)
	for offset := 0; offset < checksumBits; offset++ {
		expected := bitAt(checksum[:], offset)
		actual, err := phraseBit(parts, entropyBits+offset)
		if err != nil {
			return "", err
		}
		if actual != expected {
			return "", errors.New("invalid checksum")
		}
	}

	return strings.Join(parts, " "), nil
}

func Validate(phrase string) bool {
	_, err := Parse(phrase)
	return err == nil
}

func Seed(phrase string, passphrase string) ([]byte, error) {
	mnemonic, err := Parse(phrase)
	if err != nil {
		return nil, err
	}
	return pbkdf2SHA512([]byte(mnemonic), []byte("mnemonic"+passphrase), 2048, 64), nil
}

func SeedHex(phrase string, passphrase string) (string, error) {
	seed, err := Seed(phrase, passphrase)
	if err != nil {
		return "", err
	}
	return hex.EncodeToString(seed), nil
}

func phraseBit(parts []string, bitIndex int) (int, error) {
	wordIndex := bitIndex / 11
	offset := bitIndex % 11
	index, ok := indexByWord[parts[wordIndex]]
	if !ok {
		return 0, fmt.Errorf("unknown word: %s", parts[wordIndex])
	}
	return (index >> (10 - offset)) & 1, nil
}

func validEntropyBytes(count int) bool {
	return count == 16 || count == 20 || count == 24 || count == 28 || count == 32
}

func validWordCount(count int) bool {
	return count == 12 || count == 15 || count == 18 || count == 21 || count == 24
}

func wordsToStrength(count int) (int, error) {
	if !validWordCount(count) {
		return 0, fmt.Errorf("invalid word count: %d", count)
	}
	return count / 3 * 32, nil
}

func bitAt(data []byte, bitIndex int) int {
	return int((data[bitIndex/8] >> (7 - bitIndex%8)) & 1)
}

func setBit(data []byte, bitIndex int, value int) {
	if value == 1 {
		data[bitIndex/8] |= 1 << (7 - bitIndex%8)
	}
}

func pbkdf2SHA512(password []byte, salt []byte, iterations int, keyLen int) []byte {
	hashLen := 64
	blocks := (keyLen + hashLen - 1) / hashLen
	out := make([]byte, 0, blocks*hashLen)

	for block := 1; block <= blocks; block++ {
		counter := make([]byte, 4)
		binary.BigEndian.PutUint32(counter, uint32(block))
		u := hmacSHA512(password, append(append([]byte{}, salt...), counter...))
		t := append([]byte{}, u...)
		for i := 2; i <= iterations; i++ {
			u = hmacSHA512(password, u)
			for j := range t {
				t[j] ^= u[j]
			}
		}
		out = append(out, t...)
	}

	return out[:keyLen]
}

func hmacSHA512(key []byte, data []byte) []byte {
	mac := hmac.New(sha512.New, key)
	mac.Write(data)
	return mac.Sum(nil)
}
