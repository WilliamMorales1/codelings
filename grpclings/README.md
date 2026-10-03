# grpclings

Small exercises to get you used to **Protocol Buffers** and **gRPC**, in Go:
writing schemas, generating code, reading the wire format, evolving an API
without breaking clients, and building servers, clients, streams and
middleware.

Shamelessly modelled on [rustlings](https://github.com/rust-lang/rustlings).
Every exercise is a directory with a `.proto` file, some Go code, or both. You
fix it and save; once the check passes the exercise is done and the runner
moves you on to the next one.

## Setup

You need Go 1.26.7+, `protoc` and `jq`:

```sh
sudo pacman -S go protobuf jq                      # Arch
sudo apt install golang protobuf-compiler jq       # Debian/Ubuntu
sudo dnf install golang protobuf-compiler jq       # Fedora
brew install go protobuf jq                        # macOS
```

If your package manager's Go is older than 1.26.7, get it from [go.dev/dl](https://go.dev/dl/).
Optional: `buf` (checks fall back to the pinned `go tool buf`) and `grpcurl`
(only `08_ecosystem/ecosystem3` needs it):

```sh
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest   # anywhere
brew install grpcurl                                           # or, macOS
```

Then build the runner:

```sh
git clone https://github.com/WilliamMorales1/codelings
cd codelings/grpclings
go build -o grpclings .
./grpclings doctor
```

The code generators are pinned in `go.mod` with Go 1.24+ `tool` directives,
so you install nothing else and everyone gets the same versions:

```sh
go tool protoc-gen-go --version       # google.golang.org/protobuf v1.36.12
go tool protoc-gen-go-grpc --version  # google.golang.org/grpc/cmd/protoc-gen-go-grpc v1.6.2
go tool buf --version                 # github.com/bufbuild/buf v1.73.0
go tool -n protoc-gen-go              # path of the built binary, for protoc --plugin=
```

The libraries are `google.golang.org/grpc` v1.84.0 and, for the last
exercise, `connectrpc.com/connect` v1.21.0.

The first command that checks anything downloads the Go modules and compiles
protobuf, gRPC and the plugins once (a minute or two, plus about a minute
more for `buf` if it is not on your `PATH`). All of that lands in the normal
Go module and build caches, so later checks take a second or two.

## Usage

```sh
./grpclings watch          # the main loop: re-checks every time you save
./grpclings watch 05       # only one chapter
./grpclings                # check once, stop at the first unsolved exercise
./grpclings list           # every exercise and its status
./grpclings run unary2     # check one exercise by name
./grpclings hint unary2    # print its hint
./grpclings solution unary2
./grpclings reset unary2   # back to the original, unsolved files
./grpclings doctor         # which tools are installed, and the pinned versions
```

Open a second terminal with `grpclings watch` running, edit the files it
points at, and save. That is the whole workflow.

The `File:` line is a terminal hyperlink (OSC 8), so in kitty, foot, WezTerm,
Ghostty and friends you can click it to open the exercise. Set `NO_COLOR=1`
for plain output.

### How checks work

Most checks run `protoc` with the pinned plugins over the exercise's `.proto`
files into a temporary directory, lay that generated code plus a hidden test
(`checks/<chapter>/<name>_test.go`) over your directory with
`go test -overlay`, and run `go test`. Nothing is written into your exercise.
The `*.pb.go` files that ship next to Go exercises exist only so your editor
can resolve the generated types; if you change a `.proto`, the check uses
fresh code regardless. Proto-only checks inspect the compiled descriptors,
`04_evolution` runs `buf lint` / `buf breaking`, and `03_codegen_encoding`
runs your own `protoc` script or `buf.gen.yaml`.

## The exercises

| Chapter | What it covers |
| --- | --- |
| `00_intro` | the workflow, how checks see your code |
| `01_proto_basics` | messages and field numbers, scalar types, enums with `_UNSPECIFIED = 0`, repeated and nested messages, packages, imports, `go_package` |
| `02_proto_advanced` | maps, `oneof`, `optional` and presence, `reserved`, well-known types (`Timestamp`, `Duration`, `FieldMask`) |
| `03_codegen_encoding` | running `protoc` and `buf generate`, `proto.Marshal`, `protojson` options, `proto.Equal` / `proto.CloneOf`, decoding the wire format by hand |
| `04_evolution` | `buf lint` style rules, request/response naming, `buf breaking` with `WIRE_JSON`, renaming via deprecation |
| `05_unary_grpc` | declaring a service, implementing a server, clients with deadlines, status codes, testing with `bufconn` |
| `06_streaming` | server streaming, client streaming, a bidirectional chat room, cancellation |
| `07_middleware` | unary and stream interceptors, `slog` logging, auth via metadata, wrapped streams, deadline propagation, retry policy and keepalive |
| `08_ecosystem` | health checking, server reflection, `grpcurl`, rich error details, connect-go over plain HTTP |

41 exercises.

## Layout

```
exercises/      what you edit, one directory per exercise
solutions/      one reference solution per exercise, same shape
.templates/     pristine copies, used by `grpclings reset`
checks/         the spec: <chapter>/<name>.sh (with # REQUIRES: and # HINT)
                plus, for most, a hidden <name>_test.go (build tag `check`)
checks/lib.sh   helpers the check scripts share (go_check, run_buf, ...)
internal/check  Go helpers the hidden tests share (descriptor asserts, bufconn)
internal/warm   imports every library once, to pre-build them on first run
*.go            the runner
scripts/        verify-all.sh (maintainer self test), regen.sh
```

## Adding an exercise

1. Create `solutions/<chapter>/<name>/` with a `.proto` whose `go_package` is
   `grpclings/exercises/<chapter>/<name>;<name>`, plus any Go code (package
   `<name>`).
2. Create `exercises/<chapter>/<name>/`: the same files, broken, with a header
   comment (title, concept, task). It must fail its check as shipped.
3. Write `checks/<chapter>/<name>.sh` (a `# REQUIRES:` line, a `# HINT` block,
   then usually `source "$GRPCLINGS_LIB"; go_check`) and, for `go_check`,
   `checks/<chapter>/<name>_test.go` starting with `//go:build check` and
   `package <name>`.
4. Run `scripts/regen.sh` (generated code for editors, and `.templates/`),
   then `scripts/verify-all.sh`: every solution must pass and every untouched
   exercise must fail. Exercises whose tools are missing show up as
   SKIPPED.

Ordering is by chapter directory, then natural sort of the exercise name.

## Other ways to learn

- [protobuf.dev](https://protobuf.dev/): the language guide, [encoding](https://protobuf.dev/programming-guides/encoding/) and [best practices](https://protobuf.dev/best-practices/dos-donts/)
- [grpc.io docs](https://grpc.io/docs/languages/go/): the Go quick start and the guides on deadlines, status codes, retries, keepalive and health checking
- [grpc-go examples](https://github.com/grpc/grpc-go/tree/master/examples): one small program per feature
- [buf.build docs](https://buf.build/docs/) and the [Buf tour](https://buf.build/docs/tutorials/getting-started-with-buf-cli/)
- [connectrpc.com](https://connectrpc.com/docs/go/getting-started/): gRPC-compatible RPC over plain HTTP
