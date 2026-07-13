#!/usr/bin/env sh
set -eu

EXPECTED_PHRASE="abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
EXPECTED_SEED="c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04"

if [ "${BIP39KIT_BIN:-}" ]; then
  BIN="$BIP39KIT_BIN"
  TMPDIR_EXAMPLE=""
else
  TMPDIR_EXAMPLE="$(mktemp -d "${TMPDIR:-/tmp}/bip39kit-cli-example.XXXXXX")"
  trap 'rm -rf "$TMPDIR_EXAMPLE"' EXIT INT TERM
  curl -fsSL https://raw.githubusercontent.com/devdasx/bip39-mnemonic-kit/2.0.1/install.sh -o "$TMPDIR_EXAMPLE/install.sh"
  sh "$TMPDIR_EXAMPLE/install.sh" --version 2.0.1 --prefix "$TMPDIR_EXAMPLE/prefix" >/dev/null
  BIN="$TMPDIR_EXAMPLE/prefix/bin/bip39kit"
fi

[ "$("$BIN" version)" = "2.0.1" ]
[ "$("$BIN" entropy-to-mnemonic 00000000000000000000000000000000)" = "$EXPECTED_PHRASE" ]
[ "$("$BIN" validate "$EXPECTED_PHRASE")" = "valid" ]
[ "$("$BIN" seed "$EXPECTED_PHRASE" --passphrase TREZOR)" = "$EXPECTED_SEED" ]
"$BIN" generate --words 12 | awk '{ if (NF != 12) exit 1 }'

echo "cli-example-ok"
