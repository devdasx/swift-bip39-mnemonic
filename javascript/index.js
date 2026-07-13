import { pbkdf2 } from '@noble/hashes/pbkdf2.js';
import { sha256 as nobleSha256, sha512 } from '@noble/hashes/sha2.js';
import { bytesToHex, randomBytes as nobleRandomBytes } from '@noble/hashes/utils.js';
import { english } from './wordlist.js';

const indexByWord = new Map(english.map((word, index) => [word, index]));
const validEntropyBytes = new Set([16, 20, 24, 28, 32]);
const validWordCounts = new Set([12, 15, 18, 21, 24]);

export class BIP39Error extends Error {}

export function generateMnemonic(options = {}) {
  const strength = options.strength ?? wordsToStrength(options.words ?? 12);
  const byteCount = strength / 8;
  const randomBytes = options.randomBytes ?? defaultRandomBytes;
  return entropyToMnemonic(randomBytes(byteCount));
}

export function entropyToMnemonic(entropyInput) {
  const entropy = toUint8Array(entropyInput);
  if (!validEntropyBytes.has(entropy.length)) {
    throw new BIP39Error(`Invalid entropy byte count: ${entropy.length}`);
  }

  const entropyBits = bytesToBits(entropy);
  const checksumBits = bytesToBits(sha256(entropy)).slice(0, entropy.length * 8 / 32);
  const bits = entropyBits + checksumBits;
  const words = [];

  for (let i = 0; i < bits.length; i += 11) {
    words.push(english[parseInt(bits.slice(i, i + 11), 2)]);
  }

  return words.join(' ');
}

export function validateMnemonic(phrase) {
  try {
    parseMnemonic(phrase);
    return true;
  } catch {
    return false;
  }
}

export function parseMnemonic(phrase) {
  const words = normalizeWords(phrase);
  if (!validWordCounts.has(words.length)) {
    throw new BIP39Error(`Invalid word count: ${words.length}`);
  }

  const bits = words.map((word) => {
    const index = indexByWord.get(word);
    if (index === undefined) throw new BIP39Error(`Unknown word: ${word}`);
    return index.toString(2).padStart(11, '0');
  }).join('');

  const checksumLength = bits.length / 33;
  const entropyLength = bits.length - checksumLength;
  const entropyBits = bits.slice(0, entropyLength);
  const checksumBits = bits.slice(entropyLength);
  const entropy = bitsToBytes(entropyBits);
  const expected = bytesToBits(sha256(entropy)).slice(0, checksumLength);

  if (checksumBits !== expected) {
    throw new BIP39Error('Invalid checksum');
  }

  return words.join(' ');
}

export function mnemonicToSeed(phrase, passphrase = '') {
  const mnemonic = parseMnemonic(phrase).normalize('NFKD');
  const salt = `mnemonic${passphrase.normalize('NFKD')}`;
  return pbkdf2(sha512, utf8(mnemonic), utf8(salt), { c: 2048, dkLen: 64 });
}

export function mnemonicToSeedHex(phrase, passphrase = '') {
  return bytesToHex(mnemonicToSeed(phrase, passphrase));
}

function normalizeWords(phrase) {
  return phrase.normalize('NFKD').trim().split(/\s+/).filter(Boolean);
}

function wordsToStrength(words) {
  const value = Number(words);
  if (!validWordCounts.has(value)) throw new BIP39Error(`Invalid word count: ${words}`);
  return value / 3 * 32;
}

function defaultRandomBytes(count) {
  return nobleRandomBytes(count);
}

function sha256(data) {
  return sha256Digest(data);
}

function sha256Digest(data) {
  return nobleSha256(data);
}

function utf8(value) {
  return new TextEncoder().encode(value);
}

function toUint8Array(input) {
  if (typeof input === 'string') {
    const hex = input.startsWith('0x') ? input.slice(2) : input;
    if (hex.length % 2 !== 0) throw new BIP39Error('Invalid hex entropy');
    return Uint8Array.from(hex.match(/../g).map((byte) => parseInt(byte, 16)));
  }
  return input instanceof Uint8Array ? input : new Uint8Array(input);
}

function bytesToBits(bytes) {
  return Array.from(bytes, (byte) => byte.toString(2).padStart(8, '0')).join('');
}

function bitsToBytes(bits) {
  const out = new Uint8Array(bits.length / 8);
  for (let i = 0; i < out.length; i += 1) {
    out[i] = parseInt(bits.slice(i * 8, i * 8 + 8), 2);
  }
  return out;
}
