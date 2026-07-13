Pod::Spec.new do |s|
  s.name         = 'BIP39MnemonicKit'
  s.version      = '2.0.0'
  s.summary      = 'BIP-39 mnemonic generation, validation, and seed derivation for Swift apps.'
  s.description  = <<-DESC
    BIP39MnemonicKit is a Swift library for generating valid BIP-39 English mnemonic phrases,
    validating recovery phrases with checksum verification, and deriving BIP-39 seeds
    for wallet and seed phrase workflows.
  DESC
  s.homepage     = 'https://github.com/devdasx/bip39-mnemonic-kit'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'ROYO STUDIOS' => 'royostudios13@gmail.com' }
  s.source       = { :git => 'https://github.com/devdasx/bip39-mnemonic-kit.git', :tag => s.version.to_s }
  s.swift_versions = ['6.0']
  s.platforms    = {
    :ios => '15.0',
    :osx => '12.0'
  }
  s.source_files = 'Sources/BIP39MnemonicKit/**/*.swift'
  s.resource_bundles = {
    'BIP39MnemonicKitResources' => ['Sources/BIP39MnemonicKit/Resources/english.txt']
  }
  s.frameworks = 'CryptoKit', 'Security'
end
