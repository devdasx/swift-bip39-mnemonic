class Swiftbip39 < Formula
  desc "BIP-39 mnemonic generator, validator, and seed derivation CLI"
  homepage "https://github.com/devdasx/swift-bip39-mnemonic"
  url "https://github.com/devdasx/swift-bip39-mnemonic/archive/refs/tags/1.1.3.tar.gz"
  license "MIT"

  depends_on xcode: ["16.0", :build]
  depends_on :macos

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    libexec.install ".build/release/swiftbip39"
    libexec.install ".build/release/SwiftBIP39_SwiftBIP39.bundle"

    (bin/"swiftbip39").write <<~EOS
      #!/bin/sh
      exec "#{libexec}/swiftbip39" "$@"
    EOS
  end

  test do
    assert_match "valid",
      shell_output("#{bin}/swiftbip39 validate " \
                   "'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about'")
  end
end
