#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/bip39kit-examples.XXXXXX")"
trap 'rm -rf "$WORKDIR"' EXIT INT TERM

cp -R "$ROOT/examples" "$WORKDIR/examples"

say() {
  printf '\n==> %s\n' "$*"
}

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

python_bin() {
  if [[ -n "${PYTHON_BIN:-}" && -x "$PYTHON_BIN" ]]; then
    printf '%s' "$PYTHON_BIN"
  elif [[ -x /usr/bin/python3 ]]; then
    printf '%s' /usr/bin/python3
  else
    command -v python3
  fi
}

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

  for candidate in \
    /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home \
    /usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home; do
    if [[ -x "$candidate/bin/java" ]]; then
      export JAVA_HOME="$candidate"
      export PATH="$JAVA_HOME/bin:$PATH"
      return 0
    fi
  done
}

need swift
need sh
need node
need npm
need cargo
need go
need dart
need gradle
setup_java_home

say "Swift Package Manager"
(cd "$WORKDIR/examples/swift-spm" && swift run -c release)

say "CLI installer"
(cd "$WORKDIR/examples/cli" && sh run.sh)

say "JavaScript"
(cd "$WORKDIR/examples/javascript" && npm install >/dev/null && node example.mjs)

say "React Native entry point smoke test"
(cd "$WORKDIR/examples/react-native" && npm install >/dev/null && node smoke-test.mjs)

say "Python"
py="$(python_bin)"
(cd "$WORKDIR/examples/python" && "$py" -m venv .venv && .venv/bin/python -m pip install --upgrade pip >/dev/null && .venv/bin/python -m pip install -r requirements.txt >/dev/null && .venv/bin/python example.py)

say "Rust"
(cd "$WORKDIR/examples/rust" && cargo run --release --quiet)

say "Go"
(cd "$WORKDIR/examples/go" && GOPROXY=direct GOSUMDB=off go mod tidy && GOPROXY=direct GOSUMDB=off go run .)

say "Dart / Flutter-compatible package"
(cd "$WORKDIR/examples/dart-flutter" && dart pub get >/dev/null && dart run bin/main.dart)

say "Kotlin / JVM"
(cd "$WORKDIR/examples/kotlin" && gradle --no-daemon run --quiet)

say "All runnable examples passed"
