import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';
import {
  entropyToMnemonic,
  generateMnemonic,
  mnemonicToSeedHex,
  parseMnemonic,
  validateMnemonic
} from '../index.js';

const vectors = JSON.parse(readFileSync(new URL('./english-vectors.json', import.meta.url), 'utf8'));

test('matches official English BIP-39 vectors', () => {
  for (const vector of vectors) {
    assert.equal(entropyToMnemonic(vector.entropyHex), vector.mnemonic);
    assert.equal(parseMnemonic(vector.mnemonic), vector.mnemonic);
    assert.equal(mnemonicToSeedHex(vector.mnemonic, 'TREZOR'), vector.seedHex);
  }
});

test('generates valid mnemonics', () => {
  for (const words of [12, 15, 18, 21, 24]) {
    const mnemonic = generateMnemonic({ words });
    assert.equal(mnemonic.split(' ').length, words);
    assert.equal(validateMnemonic(mnemonic), true);
  }
});

test('rejects invalid checksum', () => {
  assert.equal(validateMnemonic('abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon'), false);
});
