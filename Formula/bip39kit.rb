class Bip39kit < Formula
  desc "BIP-39 mnemonic generator, validator, and seed derivation CLI"
  homepage "https://github.com/devdasx/bip39-mnemonic-kit"
  url "https://github.com/devdasx/bip39-mnemonic-kit/archive/refs/tags/2.0.1.tar.gz"
  sha256 "b816ef5abf0e8583f7867066727279b211e75daf40bd655790b5a471c3b13f8d"
  license "MIT"

  depends_on xcode: ["16.0", :build]
  depends_on :macos

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    libexec.install ".build/release/bip39kit"
    libexec.install ".build/release/BIP39MnemonicKit_BIP39MnemonicKit.bundle"

    (bin/"bip39kit").write <<~EOS
      #!/bin/sh
      exec "#{libexec}/bip39kit" "$@"
    EOS
  end

  test do
    assert_match "valid",
      shell_output("#{bin}/bip39kit validate " \
                   "'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about'")
  end
end
