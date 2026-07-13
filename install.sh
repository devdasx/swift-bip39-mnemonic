#!/usr/bin/env sh
set -eu

REPO="devdasx/swift-bip39-mnemonic"
BIN="swiftbip39"
VERSION="${VERSION:-latest}"
PREFIX="${PREFIX:-$HOME/.local}"

usage() {
  cat <<'EOF'
Install swiftbip39 from GitHub Releases.

Usage:
  sh install.sh [--prefix DIR] [--version VERSION] [--uninstall] [--help]

Options:
  --prefix DIR       Install prefix. Default: ~/.local
  --version VERSION  Release version, for example 1.1.2. Default: latest
  --uninstall        Remove the installed binary and resource bundle from PREFIX/bin
  --help             Show help
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --prefix)
      [ "$#" -ge 2 ] || { echo "missing --prefix value" >&2; exit 1; }
      PREFIX="$2"
      shift 2
      ;;
    --version)
      [ "$#" -ge 2 ] || { echo "missing --version value" >&2; exit 1; }
      VERSION="$2"
      shift 2
      ;;
    --uninstall)
      rm -f "$PREFIX/bin/$BIN"
      rm -rf "$PREFIX/bin/SwiftBIP39_SwiftBIP39.bundle"
      echo "removed $PREFIX/bin/$BIN"
      exit 0
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m)"

case "$os" in
  darwin) platform="macos" ;;
  linux)
    echo "Linux CLI binaries are not published yet. Use the JavaScript, Python, Go, Rust, Dart, or Kotlin packages on Linux." >&2
    exit 1
    ;;
  *) echo "unsupported OS: $os" >&2; exit 1 ;;
esac

case "$arch" in
  arm64|aarch64) cpu="arm64" ;;
  x86_64|amd64)
    echo "macOS x86_64 release binaries are not published yet. Use Homebrew to build from source: brew tap devdasx/tap && brew install swiftbip39" >&2
    exit 1
    ;;
  *) echo "unsupported architecture: $arch" >&2; exit 1 ;;
esac

if [ "$VERSION" = "latest" ]; then
  tag="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n 1)"
else
  tag="$VERSION"
fi

asset="$BIN-$platform-$cpu.tar.gz"
base="https://github.com/$REPO/releases/download/$tag"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT INT TERM

curl -fsSL "$base/$asset" -o "$tmp/$asset"
curl -fsSL "$base/checksums.txt" -o "$tmp/checksums.txt"

expected="$(grep " $asset$" "$tmp/checksums.txt" | awk '{print $1}')"
[ -n "$expected" ] || { echo "missing checksum for $asset" >&2; exit 1; }

actual="$(shasum -a 256 "$tmp/$asset" | awk '{print $1}')"
[ "$expected" = "$actual" ] || { echo "checksum mismatch for $asset" >&2; exit 1; }

tar -xzf "$tmp/$asset" -C "$tmp"
mkdir -p "$PREFIX/bin"
install -m 755 "$tmp/$BIN" "$PREFIX/bin/$BIN"
rm -rf "$PREFIX/bin/SwiftBIP39_SwiftBIP39.bundle"
cp -R "$tmp/SwiftBIP39_SwiftBIP39.bundle" "$PREFIX/bin/SwiftBIP39_SwiftBIP39.bundle"

echo "installed $BIN to $PREFIX/bin/$BIN"
case ":$PATH:" in
  *":$PREFIX/bin:"*) ;;
  *) echo "add $PREFIX/bin to PATH to run $BIN from any terminal" ;;
esac
