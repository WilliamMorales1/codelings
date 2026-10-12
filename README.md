# codelings

A collection of [rustlings](https://github.com/rust-lang/rustlings)-style courses: small, broken
exercises you fix one at a time while a runner checks your work on every save.

Every course uses the same commands (except rustlings and cplings, which keep their own runners):

```sh
cd <course>      # e.g. cd textlings
# follow that course's README to install its tools, then:
<x>lings watch   # re-check on save, move on when it passes
<x>lings hint    # stuck? get a nudge
<x>lings list    # see your progress
```

Each course's README has install commands for Arch, Debian/Ubuntu, Fedora and macOS.
On Windows, use [WSL](https://learn.microsoft.com/windows/wsl/install). netlings and systemdlings
need Linux.

## Courses

Written for this repo:

| Course | Learn |
|---|---|
| [cudalings](cudalings) | CUDA kernels, needs an NVIDIA GPU (or Colab) |
| [grpclings](grpclings) | Protocol Buffers and gRPC in Go |
| [htmxlings](htmxlings) | htmx and hypermedia patterns |
| [leanlings](leanlings) | Lean 4 |
| [netlings](netlings) | Linux networking |
| [ocamlings](ocamlings) | OCaml |
| [opslings](opslings) | Docker, Kubernetes and the ops toolbox |
| [otellings](otellings) | OpenTelemetry in Go |
| [redislings](redislings) | Redis / Valkey |
| [systemdlings](systemdlings) | systemd units |
| [tailwindlings](tailwindlings) | Tailwind CSS v4 |
| [textlings](textlings) | jq and awk |
| [tslings](tslings) | TypeScript |
| [weblings](weblings) | Node.js, React, Vite, Postgres, SQLite |

Imported from other projects (see credits below):

| Course | Learn |
|---|---|
| [clings](clings) | C |
| [cplings](cplings) | C++ |
| [dockerlings](dockerlings) | Docker |
| [erlings](erlings) | Erlang |
| [exlings](exlings) | Elixir |
| [golings](golings) | Go |
| [haskellings](haskellings) | Haskell |
| [nimlings](nimlings) | Nim |
| [nixlings](nixlings) | Nix |
| [rustlings](rustlings) | Rust |
| [ziglings](ziglings) | Zig |

## Credits

None of this would exist without [rustlings](https://github.com/rust-lang/rustlings), which
every course here is modelled on (and which is included as a course too).

The imported courses are the work of their original authors. They are included here under
their own licenses (each folder keeps its `LICENSE`), with runners adapted to the shared commands:

| Course | Original project | Authors | License |
|---|---|---|---|
| clings | [danwritecode/clings](https://github.com/danwritecode/clings) | danwritecode | MIT |
| cplings | [rdjondo/cplings](https://github.com/rdjondo/cplings) | rdjondo | MIT |
| dockerlings | [furkan/dockerlings](https://github.com/furkan/dockerlings) | Furkan Aldemir | MIT |
| erlings | [lambdaclass/erlings](https://github.com/lambdaclass/erlings) | LambdaClass | MIT |
| exlings | [zoedsoupe/exlings](https://github.com/zoedsoupe/exlings) | zoedsoupe and contributors | Apache-2.0 |
| golings | [mauricioabreu/golings](https://github.com/mauricioabreu/golings) | Mauricio Abreu | Apache-2.0 |
| haskellings | [MondayMorningHaskell/haskellings](https://github.com/MondayMorningHaskell/haskellings) | Monday Morning Haskell | BSD-3-Clause |
| nimlings | [sergiotapia/nimlings](https://github.com/sergiotapia/nimlings) | Sergio Tapia | MIT |
| nixlings | [spacekookie/nixlings](https://github.com/spacekookie/nixlings) | spacekookie | CC BY-SA 4.0 |
| rustlings | [rust-lang/rustlings](https://github.com/rust-lang/rustlings) | Carol Nichols and contributors | MIT |
| ziglings | [ziglings/exercises](https://codeberg.org/ziglings/exercises) | Dave Gauer, Chris Boesch and contributors | MIT |

If you like a course, go star the original.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the layout and conventions every course follows.

## License

The courses written for this repo, and the shared files at the root, are [MIT](LICENSE).
Each imported course keeps its original license, in its own folder's `LICENSE`.
