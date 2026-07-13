# Go example

This example installs the Go v2 module from GitHub and imports the `go/bip39` subpackage.

## Install

```bash
go get github.com/devdasx/bip39-mnemonic-kit/v2@v2.0.1
```

Then import:

```go
import "github.com/devdasx/bip39-mnemonic-kit/v2/go/bip39"
```

## Run

```bash
GOPROXY=direct GOSUMDB=off go run .
```

`GOPROXY=direct` is useful immediately after a new GitHub tag because the public Go checksum proxy can lag behind GitHub.
