#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/devdasx/bip39-mnemonic-kit.git}"
GITHUB_SLUG="${GITHUB_SLUG:-devdasx/bip39-mnemonic-kit}"
REF="${REF:-2.0.1}"
WORKDIR=""
INSTALL_MISSING=0
KEEP_WORKDIR=0
RUN_HOMEBREW=0

EXPECTED_PHRASE="abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
EXPECTED_SEED="c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04"
ENTROPY_HEX="00000000000000000000000000000000"

usage() {
  cat <<'USAGE'
Usage: scripts/test-consumer-packages.sh [options]

Creates fresh temporary consumer projects and verifies GitHub-sourced installs for:
Swift Package Manager, CLI installer, Node.js, React Native entry point, Python,
Rust, Go, Dart/Flutter-compatible package, Kotlin/JVM, and optionally Homebrew.

Options:
  --ref VERSION_OR_BRANCH   Git ref/tag to install from. Default: 2.0.1
  --repo URL                Git repo URL. Default: https://github.com/devdasx/bip39-mnemonic-kit.git
  --github-slug OWNER/REPO  GitHub slug used by npm/JitPack. Default: devdasx/bip39-mnemonic-kit
  --workdir DIR             Reuse/create a specific scratch directory.
  --install-missing         Install missing go/rust/dart/gradle with Homebrew when possible.
  --include-homebrew        Also test brew install devdasx/tap/bip39kit.
  --keep-workdir            Do not delete the scratch directory.
  -h, --help                Show this help.

Environment overrides:
  SWIFT_BIN, NODE_BIN, NPM_BIN, PYTHON_BIN, CARGO_BIN, GO_BIN, DART_BIN, GRADLE_BIN, BREW_BIN
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref)
      REF="$2"
      shift 2
      ;;
    --repo)
      REPO_URL="$2"
      shift 2
      ;;
    --github-slug)
      GITHUB_SLUG="$2"
      shift 2
      ;;
    --workdir)
      WORKDIR="$2"
      shift 2
      ;;
    --install-missing)
      INSTALL_MISSING=1
      shift
      ;;
    --include-homebrew)
      RUN_HOMEBREW=1
      shift
      ;;
    --keep-workdir)
      KEEP_WORKDIR=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$WORKDIR" ]]; then
  WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/bip39kit-consumer-tests.XXXXXX")"
else
  mkdir -p "$WORKDIR"
fi

cleanup() {
  if [[ "$KEEP_WORKDIR" -eq 0 ]]; then
    rm -rf "$WORKDIR"
  else
    echo "Scratch directory kept: $WORKDIR"
  fi
}
trap cleanup EXIT

say() {
  printf '\n==> %s\n' "$*"
}

pass() {
  printf '✓ %s\n' "$*"
}

have() {
  command -v "$1" >/dev/null 2>&1
}

need_command() {
  local var_name="$1"
  local command_name="$2"
  local brew_package="${3:-$2}"
  local current="${!var_name:-}"

  if [[ -n "$current" && -x "$current" ]]; then
    printf '%s' "$current"
    return 0
  fi

  if have "$command_name"; then
    command -v "$command_name"
    return 0
  fi

  if [[ "$INSTALL_MISSING" -eq 1 ]]; then
    local brew="${BREW_BIN:-}"
    if [[ -z "$brew" && -x /opt/homebrew/bin/brew ]]; then
      brew=/opt/homebrew/bin/brew
    elif [[ -z "$brew" && -x /usr/local/bin/brew ]]; then
      brew=/usr/local/bin/brew
    elif [[ -z "$brew" ]] && have brew; then
      brew="$(command -v brew)"
    fi

    if [[ -n "$brew" ]]; then
      say "Installing missing $command_name with Homebrew package $brew_package"
      if [[ "$brew_package" == "dart" ]]; then
        "$brew" tap dart-lang/dart >/dev/null
      fi
      "$brew" install "$brew_package"
      command -v "$command_name"
      return 0
    fi
  fi

  echo "Missing required command: $command_name. Re-run with --install-missing or set $var_name." >&2
  exit 1
}

assert_eq() {
  local actual="$1"
  local expected="$2"
  local label="$3"
  if [[ "$actual" != "$expected" ]]; then
    echo "Assertion failed: $label" >&2
    echo "Expected: $expected" >&2
    echo "Actual:   $actual" >&2
    exit 1
  fi
}

swift_bin="$(need_command SWIFT_BIN swift swift)"
node_bin="$(need_command NODE_BIN node node)"
npm_bin="$(need_command NPM_BIN npm node)"
python_bin="$(need_command PYTHON_BIN python3 python)"
cargo_bin="$(need_command CARGO_BIN cargo rust)"
go_bin="$(need_command GO_BIN go go)"
dart_bin="$(need_command DART_BIN dart dart)"
gradle_bin="$(need_command GRADLE_BIN gradle gradle)"

setup_java_home() {
  if [[ -n "${JAVA_HOME:-}" && -x "$JAVA_HOME/bin/java" ]]; then
    return 0
  fi

  if [[ -x /usr/libexec/java_home ]]; then
    local java_home
    java_home="$(/usr/libexec/java_home -v 17 2>/dev/null || true)"
    if [[ -n "$java_home" && -x "$java_home/bin/java" ]]; then
      export JAVA_HOME="$java_home"
      export PATH="$JAVA_HOME/bin:$PATH"
      return 0
    fi
  fi

  local brew_java_home=""
  for candidate in \
    /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home \
    /usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home; do
    if [[ -x "$candidate/bin/java" ]]; then
      brew_java_home="$candidate"
      break
    fi
  done

  if [[ -z "$brew_java_home" && "$INSTALL_MISSING" -eq 1 ]]; then
    local brew="${BREW_BIN:-}"
    if [[ -z "$brew" && -x /opt/homebrew/bin/brew ]]; then
      brew=/opt/homebrew/bin/brew
    elif [[ -z "$brew" && -x /usr/local/bin/brew ]]; then
      brew=/usr/local/bin/brew
    elif [[ -z "$brew" ]] && have brew; then
      brew="$(command -v brew)"
    fi
    if [[ -n "$brew" ]]; then
      say "Installing Java 17 with Homebrew package openjdk@17"
      "$brew" install openjdk@17
      for candidate in \
        /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home \
        /usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home; do
        if [[ -x "$candidate/bin/java" ]]; then
          brew_java_home="$candidate"
          break
        fi
      done
    fi
  fi

  if [[ -n "$brew_java_home" ]]; then
    export JAVA_HOME="$brew_java_home"
    export PATH="$JAVA_HOME/bin:$PATH"
    return 0
  fi

  echo "Missing Java 17. Install openjdk@17 or set JAVA_HOME to a Java 17 JDK." >&2
  exit 1
}

setup_java_home

say "Using scratch directory $WORKDIR"
say "Testing GitHub source $REPO_URL at ref $REF"

test_swift_spm() {
  say "Swift Package Manager consumer"
  local dir="$WORKDIR/swift-consumer"
  mkdir -p "$dir/Sources/Consumer"
  cat > "$dir/Package.swift" <<SWIFT_PACKAGE
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BIP39KitConsumer",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "$REPO_URL", exact: "$REF")
    ],
    targets: [
        .executableTarget(
            name: "Consumer",
            dependencies: [
                .product(name: "BIP39MnemonicKit", package: "bip39-mnemonic-kit")
            ]
        )
    ]
)
SWIFT_PACKAGE
  cat > "$dir/Sources/Consumer/main.swift" <<'SWIFT'
import BIP39MnemonicKit
import Foundation

let expectedPhrase = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
let expectedSeed = "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04"
let entropy = Data(repeating: 0, count: 16)
let phrase = try BIP39.mnemonic(from: entropy).phrase
precondition(phrase == expectedPhrase, phrase)
precondition(BIP39.validate(phrase))
precondition(!BIP39.validate(phrase.replacingOccurrences(of: "about", with: "above")))
let seed = try BIP39.seed(from: phrase, passphrase: "TREZOR").hex
precondition(seed == expectedSeed, seed)
precondition(try BIP39.generate(strength: .bits128).words.count == 12)
print("swift-ok")

extension Data {
    var hex: String { map { String(format: "%02x", $0) }.joined() }
}
SWIFT
  (cd "$dir" && "$swift_bin" run -c release Consumer | grep -q "swift-ok")
  pass "Swift Package Manager"
}

test_cli_installer() {
  say "CLI installer from GitHub release"
  local dir="$WORKDIR/cli-consumer"
  local prefix="$dir/prefix"
  mkdir -p "$dir" "$prefix"
  curl -fsSL "https://raw.githubusercontent.com/${GITHUB_SLUG}/${REF}/install.sh" -o "$dir/install.sh"
  sh "$dir/install.sh" --version "$REF" --prefix "$prefix"
  local bin="$prefix/bin/bip39kit"
  assert_eq "$("$bin" version)" "$REF" "CLI version"
  assert_eq "$("$bin" entropy-to-mnemonic "$ENTROPY_HEX")" "$EXPECTED_PHRASE" "CLI entropy-to-mnemonic"
  assert_eq "$("$bin" validate "$EXPECTED_PHRASE")" "valid" "CLI validate"
  assert_eq "$("$bin" seed "$EXPECTED_PHRASE" --passphrase TREZOR)" "$EXPECTED_SEED" "CLI seed"
  "$bin" generate --words 12 | awk '{ if (NF != 12) exit 1 }'
  pass "CLI installer"
}

test_homebrew() {
  if [[ "$RUN_HOMEBREW" -eq 0 ]]; then
    return 0
  fi
  say "Homebrew tap consumer"
  local brew="${BREW_BIN:-}"
  if [[ -z "$brew" && -x /opt/homebrew/bin/brew ]]; then
    brew=/opt/homebrew/bin/brew
  elif [[ -z "$brew" && -x /usr/local/bin/brew ]]; then
    brew=/usr/local/bin/brew
  elif [[ -z "$brew" ]] && have brew; then
    brew="$(command -v brew)"
  fi
  [[ -n "$brew" ]] || { echo "Homebrew is required for --include-homebrew" >&2; exit 1; }
  "$brew" tap devdasx/tap >/dev/null
  "$brew" reinstall devdasx/tap/bip39kit --build-from-source
  assert_eq "$(bip39kit validate "$EXPECTED_PHRASE")" "valid" "Homebrew CLI validate"
  pass "Homebrew tap"
}

test_node_and_react_native() {
  say "Node.js and React Native entry point consumers"
  local dir="$WORKDIR/node-consumer"
  mkdir -p "$dir"
  (cd "$dir" && "$npm_bin" init -y >/dev/null && "$npm_bin" install "github:${GITHUB_SLUG}#$REF" >/dev/null)
  cat > "$dir/test.mjs" <<'JS'
import {
  entropyToMnemonic,
  generateMnemonic,
  mnemonicToSeedHex,
  validateMnemonic
} from "bip39-mnemonic-kit";
import {
  entropyToMnemonic as rnEntropyToMnemonic,
  generateMnemonic as rnGenerateMnemonic,
  mnemonicToSeedHex as rnMnemonicToSeedHex,
  validateMnemonic as rnValidateMnemonic
} from "bip39-mnemonic-kit/react-native";

const expectedPhrase = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";
const expectedSeed = "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04";
const entropy = "00000000000000000000000000000000";

function check(condition, label) {
  if (!condition) throw new Error(label);
}

check(entropyToMnemonic(entropy) === expectedPhrase, "node entropy");
check(validateMnemonic(expectedPhrase), "node validate");
check(!validateMnemonic(expectedPhrase.replace("about", "above")), "node invalid validate");
check(mnemonicToSeedHex(expectedPhrase, "TREZOR") === expectedSeed, "node seed");
check(generateMnemonic({ words: 12 }).split(/\s+/).length === 12, "node generate");

check(rnEntropyToMnemonic(entropy) === expectedPhrase, "rn entropy");
check(rnValidateMnemonic(expectedPhrase), "rn validate");
check(rnMnemonicToSeedHex(expectedPhrase, "TREZOR") === expectedSeed, "rn seed");
check(rnGenerateMnemonic({
  words: 12,
  randomBytes: (count) => new Uint8Array(count)
}) === expectedPhrase, "rn deterministic generate");

console.log("node-react-native-ok");
JS
  (cd "$dir" && "$node_bin" test.mjs | grep -q "node-react-native-ok")
  pass "Node.js and React Native entry point"
}

test_python() {
  say "Python consumer"
  local dir="$WORKDIR/python-consumer"
  mkdir -p "$dir"
  "$python_bin" -m venv "$dir/.venv"
  "$dir/.venv/bin/python" -m pip install --upgrade pip >/dev/null
  "$dir/.venv/bin/python" -m pip install "git+$REPO_URL@$REF" >/dev/null
  cat > "$dir/test.py" <<'PY'
from bip39_mnemonic_kit import (
    entropy_to_mnemonic,
    generate_mnemonic,
    mnemonic_to_seed_hex,
    validate_mnemonic,
)

expected_phrase = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
expected_seed = "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04"
assert entropy_to_mnemonic("00000000000000000000000000000000") == expected_phrase
assert validate_mnemonic(expected_phrase)
assert not validate_mnemonic(expected_phrase.replace("about", "above"))
assert mnemonic_to_seed_hex(expected_phrase, "TREZOR") == expected_seed
assert len(generate_mnemonic(12).split()) == 12
print("python-ok")
PY
  "$dir/.venv/bin/python" "$dir/test.py" | grep -q "python-ok"
  pass "Python"
}

test_rust() {
  say "Rust consumer"
  local dir="$WORKDIR/rust-consumer"
  mkdir -p "$dir/src"
  cat > "$dir/Cargo.toml" <<RUST_TOML
[package]
name = "bip39kit-rust-consumer"
version = "0.1.0"
edition = "2021"

[dependencies]
bip39-mnemonic-kit = { git = "$REPO_URL", tag = "$REF" }
RUST_TOML
  cat > "$dir/src/main.rs" <<'RUST'
use bip39_mnemonic_kit::{
    entropy_hex_to_mnemonic, generate_mnemonic, mnemonic_to_seed_hex, validate_mnemonic,
};

fn main() {
    let expected_phrase = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";
    let expected_seed = "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04";
    assert_eq!(entropy_hex_to_mnemonic("00000000000000000000000000000000").unwrap(), expected_phrase);
    assert!(validate_mnemonic(expected_phrase));
    assert!(!validate_mnemonic(&expected_phrase.replace("about", "above")));
    assert_eq!(mnemonic_to_seed_hex(expected_phrase, "TREZOR").unwrap(), expected_seed);
    assert_eq!(generate_mnemonic(12).unwrap().split_whitespace().count(), 12);
    println!("rust-ok");
}
RUST
  (cd "$dir" && "$cargo_bin" run --release --quiet | grep -q "rust-ok")
  pass "Rust"
}

test_go() {
  say "Go consumer"
  local dir="$WORKDIR/go-consumer"
  mkdir -p "$dir"
  (cd "$dir" && "$go_bin" mod init bip39kit-go-consumer >/dev/null)
  (cd "$dir" && "$go_bin" get "github.com/${GITHUB_SLUG}/v2/go/bip39@v$REF")
  cat > "$dir/main.go" <<'GO'
package main

import (
	"fmt"
	"strings"

	"github.com/devdasx/bip39-mnemonic-kit/v2/go/bip39"
)

func main() {
	expectedPhrase := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	expectedSeed := "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04"
	phrase, err := bip39.EntropyHexToMnemonic("00000000000000000000000000000000")
	if err != nil || phrase != expectedPhrase {
		panic(fmt.Sprintf("entropy failed: %s %v", phrase, err))
	}
	if !bip39.Validate(expectedPhrase) {
		panic("validate failed")
	}
	if bip39.Validate(strings.Replace(expectedPhrase, "about", "above", 1)) {
		panic("invalid validate failed")
	}
	seed, err := bip39.SeedHex(expectedPhrase, "TREZOR")
	if err != nil || seed != expectedSeed {
		panic(fmt.Sprintf("seed failed: %s %v", seed, err))
	}
	generated, err := bip39.Generate(12)
	if err != nil || len(strings.Fields(generated)) != 12 {
		panic("generate failed")
	}
	fmt.Println("go-ok")
}
GO
  (cd "$dir" && "$go_bin" run . | grep -q "go-ok")
  pass "Go"
}

test_dart() {
  say "Dart consumer for Dart and Flutter package usage"
  local dir="$WORKDIR/dart-consumer"
  mkdir -p "$dir/bin"
  cat > "$dir/pubspec.yaml" <<DART_YAML
name: bip39kit_dart_consumer
environment:
  sdk: ">=3.0.0 <4.0.0"
dependencies:
  bip39_mnemonic_kit:
    git:
      url: $REPO_URL
      ref: $REF
DART_YAML
  cat > "$dir/bin/main.dart" <<'DART'
import 'package:bip39_mnemonic_kit/bip39_mnemonic_kit.dart';

void check(bool condition, String label) {
  if (!condition) throw StateError(label);
}

void main() {
  const expectedPhrase = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
  const expectedSeed = 'c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04';
  check(entropyHexToMnemonic('00000000000000000000000000000000') == expectedPhrase, 'entropy');
  check(validateMnemonic(expectedPhrase), 'validate');
  check(!validateMnemonic(expectedPhrase.replaceFirst('about', 'above')), 'invalid validate');
  check(mnemonicToSeedHex(expectedPhrase, passphrase: 'TREZOR') == expectedSeed, 'seed');
  check(generateMnemonic(words: 12).split(RegExp(r'\s+')).length == 12, 'generate');
  print('dart-flutter-ok');
}
DART
  (cd "$dir" && "$dart_bin" pub get >/dev/null && "$dart_bin" run bin/main.dart | grep -q "dart-flutter-ok")
  pass "Dart and Flutter-compatible package"
}

test_kotlin() {
  say "Kotlin/JVM consumer through JitPack"
  local dir="$WORKDIR/kotlin-consumer"
  mkdir -p "$dir/src/main/kotlin"
  cat > "$dir/settings.gradle.kts" <<'KOTLIN_SETTINGS'
pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        mavenCentral()
        maven("https://jitpack.io")
    }
}
rootProject.name = "bip39kit-kotlin-consumer"
KOTLIN_SETTINGS
  cat > "$dir/build.gradle.kts" <<KOTLIN_GRADLE
plugins {
    kotlin("jvm") version "2.0.21"
    application
}

dependencies {
    implementation("com.github.${GITHUB_SLUG//\//:}:$REF")
}

application {
    mainClass.set("ConsumerKt")
}
KOTLIN_GRADLE
  cat > "$dir/src/main/kotlin/Consumer.kt" <<'KOTLIN'
import com.devdasx.bip39mnemonickit.Bip39

fun check(condition: Boolean, label: String) {
    if (!condition) error(label)
}

fun main() {
    val expectedPhrase = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
    val expectedSeed = "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04"
    check(Bip39.entropyHexToMnemonic("00000000000000000000000000000000") == expectedPhrase, "entropy")
    check(Bip39.validateMnemonic(expectedPhrase), "validate")
    check(!Bip39.validateMnemonic(expectedPhrase.replaceFirst("about", "above")), "invalid validate")
    check(Bip39.mnemonicToSeedHex(expectedPhrase, "TREZOR") == expectedSeed, "seed")
    check(Bip39.generateMnemonic(12).split(Regex("\\s+")).size == 12, "generate")
    println("kotlin-ok")
}
KOTLIN
  (cd "$dir" && "$gradle_bin" --no-daemon run --quiet | grep -q "kotlin-ok")
  pass "Kotlin/JVM"
}

test_swift_spm
test_cli_installer
test_homebrew
test_node_and_react_native
test_python
test_rust
test_go
test_dart
test_kotlin

say "All GitHub-sourced consumer package tests passed"
