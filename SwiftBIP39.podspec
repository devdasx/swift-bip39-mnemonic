Pod::Spec.new do |s|
  s.name         = 'SwiftBIP39'
  s.version      = '1.1.3'
  s.summary      = 'Swift BIP-39 mnemonic generation, validation, and seed derivation for Apple platforms.'
  s.description  = <<-DESC
    SwiftBIP39 is a Swift library for generating valid BIP-39 English mnemonic phrases,
    validating recovery phrases with checksum verification, and deriving BIP-39 seeds
    for wallet and seed phrase workflows.
  DESC
  s.homepage     = 'https://github.com/devdasx/swift-bip39-mnemonic'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'ROYO STUDIOS' => 'royostudios13@gmail.com' }
  s.source       = { :git => 'https://github.com/devdasx/swift-bip39-mnemonic.git', :tag => s.version.to_s }
  s.swift_versions = ['6.0']
  s.platforms    = {
    :ios => '15.0',
    :osx => '12.0'
  }
  s.source_files = 'Sources/SwiftBIP39/**/*.swift'
  s.resource_bundles = {
    'SwiftBIP39Resources' => ['Sources/SwiftBIP39/Resources/english.txt']
  }
  s.frameworks = 'CryptoKit', 'Security'
end
