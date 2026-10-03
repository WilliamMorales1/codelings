# otellings

Small exercises to get you used to **OpenTelemetry in Go**: traces, context
propagation, metrics, logs, resources and exporters, plus configuring the
**OpenTelemetry Collector**.

Shamelessly modelled on [rustlings](https://github.com/rust-lang/rustlings).
Every exercise is a directory with a small Go package (or a collector
`config.yaml`) that is wrong or unfinished. You fix it and save;
once the check passes the exercise is done and the runner moves you on.

There is no Jaeger, no Grafana and no docker involved. Each check is an
ordinary Go test, hidden in `checks/`, that plugs an in-memory exporter into
your code (`tracetest.SpanRecorder`, `sdkmetric.ManualReader`, an in-memory
log processor) and asserts on the spans, metrics and log records you
produced. The collector chapter runs a real `otelcol-contrib` on free local
ports and reads its debug exporter output.

Built and tested against otel-go **v1.46.0** (log **v0.22.0**, semconv
**v1.43.0**), otelhttp **v0.71.0**, otelslog **v0.20.1**, and
otelcol-contrib **0.162.0**.

## Setup

You need Go 1.27 or newer:

```sh
sudo pacman -S go          # Arch
sudo apt install golang    # Debian/Ubuntu
sudo dnf install golang    # Fedora
brew install go            # macOS
```

If your package manager's Go is older than 1.27, get it from [go.dev/dl](https://go.dev/dl/).

The collector chapter (`08_collector`) needs `otelcol-contrib` on your `PATH`.
Distro packages tend to lag behind and miss the current exporter names, so
take the release binary (swap `linux_amd64` for `linux_arm64`, `darwin_arm64`
or `darwin_amd64` to match your machine):

```sh
mkdir -p ~/.local/bin
curl -L https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.162.0/otelcol-contrib_0.162.0_linux_amd64.tar.gz \
  | tar xz -C ~/.local/bin otelcol-contrib
```

(It is a 400 MB static binary; nothing else is installed.) Chapters whose
tools are missing are shown as `NO TOOL`, so you can do 00-07 without it.

Then build the runner and fetch the Go modules once:

```sh
git clone https://github.com/WilliamMorales1/codelings
cd codelings/otellings
go build -o otellings .
./otellings doctor      # checks tools, runs `go mod download`
```

The first check compiles the OpenTelemetry SDK (a few seconds); after that
the Go build and test caches make a re-check take well under a second.

## Usage

```sh
./otellings watch          # the main loop: re-checks every time you save
./otellings                # check once, stop at the first unsolved exercise
./otellings list           # every exercise and its status
./otellings run tracing3   # check one exercise by name
./otellings hint tracing3  # print its hint
./otellings solution tracing3
./otellings reset tracing3 # back to the original, unsolved files
./otellings watch 05       # only chapter 05_metrics
```

With fish, put it on your `PATH` for the session:

```sh
set -gx PATH $PWD $PATH
otellings watch
```

Open a second terminal with `otellings watch` running, edit the file it
points at, and save. The `File:` line is an OSC 8 hyperlink (kitty, foot,
WezTerm, Ghostty, recent VTE...), so you can click it. `NO_COLOR=1` gives
plain output.

The exercises live inside one Go module (`go.mod` at the root), so gopls
gives you completion and docs in `exercises/` out of the box.

## The exercises

| Chapter | What it covers |
| --- | --- |
| `00_intro` | the workflow |
| `01_tracing_basics` | installing a TracerProvider, Shutdown flushing the batch, `defer span.End()`, low-cardinality span names, parent/child through `context.Context`, `trace.SpanFromContext` |
| `02_span_details` | typed attributes, semantic conventions (`semconv/v1.43.0`), events, `RecordError` + `SetStatus`, HTTP status rules for client vs server, span kinds, links |
| `03_propagation` | W3C `traceparent` inject and extract over HTTP headers, the global composite propagator, baggage, `MapCarrier` through a message queue |
| `04_instrumentation` | `otelhttp` server handler and client transport, keeping the context through a middleware chain, `TraceIDRatioBased` and `ParentBased` sampling |
| `05_metrics` | MeterProvider + reader, counters with units and attributes, up-down counters, histograms in seconds with explicit buckets, views, observable gauges, attribute cardinality |
| `06_logs` | the `otelslog` bridge, trace/span IDs on log records, severity and structured attributes |
| `07_resources_exporters` | `service.name`/`service.version` resources, `OTEL_SERVICE_NAME`/`OTEL_RESOURCE_ATTRIBUTES`, OTLP exporter configured by `OTEL_EXPORTER_OTLP_*`, batch vs simple span processor |
| `08_collector` | receivers/exporters/pipelines, `memory_limiter` + `batch`, the `attributes` processor, dropping spans with the `filter` processor (OTTL), fan-out with `${env:...}`, a Go program exporting to a live collector |

44 exercises.

### Watching real traces (optional)

Nothing in the course needs a UI, but to see your own program's traces:

- [otel-tui](https://github.com/ymtdzzz/otel-tui) (install options in its README)
  is a terminal OTLP receiver and trace viewer. Run `otel-tui`, then point a
  program at it with `OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318`.
- Jaeger v2 ships as a single binary on its
  [releases page](https://github.com/jaegertracing/jaeger/releases); run
  `./jaeger` and open http://localhost:16686. It accepts OTLP on 4317/4318.
- Or run `otelcol-contrib --config exercises/08_collector/collector1/config.yaml`
  and read the debug exporter's output.

## Layout

```
exercises/       the packages and configs you edit
solutions/       one reference solution per exercise
.templates/      pristine copies, used by `otellings reset`
checks/          the hidden checks: <chapter>/<name>_test.go, plus checkutil/ helpers
*.go             the runner (standard library only)
scripts/         verify-all.sh: every solution passes, every exercise really is broken
.work/           scratch Go modules the checks run in (git-ignored)
```

A check copies the exercise, the check file and `checks/checkutil` into
`.work/<variant>/<chapter>/<name>/` together with the course's `go.mod`, and
runs `go test` there. The check files carry a `//go:build otellings_check`
tag so they never interfere with the main module.

## Adding an exercise

1. Write `checks/<chapter>/<name>_test.go`: build tag `//go:build
   otellings_check`, an optional `// REQUIRES: tool ...` line for tools
   besides `go`, a `/* HINT ... */` block, and `package <name>`. Tests can
   use the helpers in `checks/checkutil`.
2. Put the broken version in `exercises/<chapter>/<name>/`, with a header
   comment (title, idea, task) that fails its check as shipped, and the fixed
   version in `solutions/<chapter>/<name>/`.
3. Copy the exercise to `.templates/<chapter>/<name>/`.
4. Run `scripts/verify-all.sh` (it accepts a chapter prefix, and `-v` to show
   how each untouched exercise fails).

Ordering is by chapter directory, then natural sort of the exercise name
(`metrics2` before `metrics10`). Names must be unique across the course.

## Other ways to learn OpenTelemetry

- [opentelemetry.io/docs/languages/go](https://opentelemetry.io/docs/languages/go/) — the official Go getting-started and instrumentation guides
- [pkg.go.dev/go.opentelemetry.io/otel](https://pkg.go.dev/go.opentelemetry.io/otel) — API docs, with runnable examples
- [OpenTelemetry semantic conventions](https://opentelemetry.io/docs/specs/semconv/) — what to call things
- [Collector docs](https://opentelemetry.io/docs/collector/) and the [contrib components](https://github.com/open-telemetry/opentelemetry-collector-contrib) READMEs
- [OTTL](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/pkg/ottl/README.md) — the language used by filter/transform processors
- [The OpenTelemetry demo](https://opentelemetry.io/docs/demo/) — a polyglot microservice shop, fully instrumented (needs docker or Kubernetes)
