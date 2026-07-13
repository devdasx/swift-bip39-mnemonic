import React, { useMemo } from "react";
import { Text, View } from "react-native";
import { generateMnemonic, validateMnemonic } from "bip39-mnemonic-kit/react-native";

function secureRandomBytes(count: number): Uint8Array {
  // Replace this demo implementation with your app's production secure random provider.
  // Examples: react-native-get-random-values, expo-crypto, or a native crypto bridge.
  const bytes = new Uint8Array(count);
  crypto.getRandomValues(bytes);
  return bytes;
}

export default function App() {
  const phrase = useMemo(
    () => generateMnemonic({ words: 12, randomBytes: secureRandomBytes }),
    []
  );

  const valid = validateMnemonic(phrase);

  return (
    <View>
      <Text>BIP39 Mnemonic Kit React Native example</Text>
      <Text>Generated words: {phrase.split(/\s+/).length}</Text>
      <Text>Valid checksum: {valid ? "yes" : "no"}</Text>
    </View>
  );
}
