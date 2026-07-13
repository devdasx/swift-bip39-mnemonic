export {
  BIP39Error,
  entropyToMnemonic,
  mnemonicToSeed,
  mnemonicToSeedHex,
  parseMnemonic,
  validateMnemonic
} from './index.js';

import { generateMnemonic as generateWithNodeDefault } from './index.js';

export function generateMnemonic(options = {}) {
  if (!options.randomBytes) {
    throw new Error('React Native requires generateMnemonic({ randomBytes }) with a secure random byte provider.');
  }
  return generateWithNodeDefault(options);
}
