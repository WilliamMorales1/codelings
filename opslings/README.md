# opslings

Small exercises to get you used to the everyday ops toolbox: **Docker**,
**Kubernetes**, and the Go-written tools around them — yq, Helm, k6,
Prometheus, OpenTofu, Caddy and kind.

Shamelessly modelled on [rustlings](https://github.com/rust-lang/rustlings).
Every exercise is a small directory of config — a Dockerfile, a manifest, a
chart, a load-test script, a rules file — broken in a small, realistic way.
You fix it and save, and a check script runs the real tool against your
files to decide whether you got it right. Once it passes, the exercise is
done and the runner moves on: there is no marker to delete.

Most chapters work fully offline on a laptop: no cluster, no cloud account,
no provider downloads. Only `02_docker` needs a Docker daemon, and only
`09_cluster` spins up a real (two-node, kind) cluster.

## Setup

The runner is a single Go binary with no dependencies outside the standard
library (Go 1.27 or newer):

```sh
git clone https://github.com/WilliamMorales1/codelings
cd codelings/opslings
go build -o opslings .
```

Or install it into `~/go/bin`:

```sh
go install .
```

(Make sure `~/go/bin` is on your `PATH`.)

Then install the tools for the chapters you want. `opslings doctor` shows
what is present and prints the install command for the rest:

```sh
# macOS, or Linux with Homebrew (the easiest route on Debian/Ubuntu/Fedora,
# which don't package most of these)
brew install yq kubeconform helm k6 prometheus opentofu caddy jq curl kind kubectl

# Arch
sudo pacman -S go-yq kubeconform helm prometheus opentofu caddy jq curl kind kubectl
yay -S k6-bin                       # AUR, or a release from github.com/grafana/k6
```

Chapters 02 and 09 also need Docker with the compose and buildx plugins:
[Docker Engine](https://docs.docker.com/engine/install/) on Linux (then
`sudo usermod -aG docker $USER` and log back in), or Docker Desktop /
[colima](https://github.com/abiosoft/colima) on macOS. Arch:
`sudo pacman -S docker docker-buildx docker-compose && sudo systemctl enable --now docker.socket`.

`prometheus` is only needed for `promtool`. `kubeconform` downloads the
Kubernetes JSON schemas on first use and caches them in
`~/.cache/opslings/kubeconform`, so after one run chapter 03 works offline.

## Usage

```sh
opslings watch          # the main loop: re-checks every time you save
opslings                # check once, stop at the first unsolved exercise
opslings list           # every exercise and its status
opslings run helm3      # check one exercise by name
opslings hint helm3     # print its hint
opslings solution helm3
opslings reset helm3    # back to the original, broken files
opslings doctor         # which tools are installed
opslings watch 05       # only chapter 05 (any chapter-name prefix works)
```

If you built with `go build`, run it as `./opslings` from the repo, or
`set -gx PATH $PWD $PATH` in fish. It finds the course from any directory
inside it.

Open a second terminal with `opslings watch` running, edit the files it
points at, and save. That is the whole workflow. Each exercise opens with a
comment block explaining the idea, the task, and the commands to try it
yourself; do try them — reading real tool output is half the skill.

The `File:` line is a terminal hyperlink, so in a terminal that supports OSC 8
(kitty, foot, WezTerm, Ghostty, recent VTE, iTerm2, Windows Terminal) you can
click or ctrl-click it to open the exercise in your editor. Set `NO_COLOR=1`
for plain output.

Exercises whose tools are missing show up as `NO TOOL`. If you skip Docker for
now, work through the other chapters with `opslings watch 03` and so on.

### The practice API

The k6 and Caddy chapters need something to talk to. `opslings target` is a
small HTTP API built into the runner:

```sh
opslings target --port 8080
```

| Endpoint | What it does |
| --- | --- |
| `GET /` | plain-text greeting |
| `GET /api/items`, `GET /api/items/{id}` | a JSON list, one item (404 if unknown) |
| `POST /api/login` | `{"username":"ops","password":"lings"}` returns `{"token": ...}` |
| `GET /api/me` | needs `Authorization: Bearer <token>`, 401 otherwise |
| `GET /slow?ms=N` | answers after N ms |
| `GET /flaky` | every third request is a 500 |
| `GET /__stats`, `POST /__reset` | request counts by `METHOD path status`, and a reset |

The checks start their own copy on a free port, so yours can keep running.

## The exercises

| Chapter | Tool | What it covers |
| --- | --- | --- |
| `00_intro` | — | the workflow |
| `01_yq` | yq | reading fields, `select` across multi-document files, editing YAML in place |
| `02_docker` | docker | `FROM`/`CMD`, `COPY`/`WORKDIR`, `ARG` vs `ENV`, `.dockerignore`, multi-stage builds, `USER` + `HEALTHCHECK`, `ENTRYPOINT` vs `CMD`, Compose |
| `03_kubernetes` | kubeconform, yq | Pods, Deployment selectors, Services and named ports, ConfigMaps, resources and probes, Secrets, Ingress v1, RBAC |
| `04_helm` | helm | `Chart.yaml`, values, `_helpers.tpl` with `include`/`nindent`, `if`/`range`, `default`/`required` |
| `05_k6` | k6 | GET requests, VUs and duration, checks and thresholds, `setup()` and bearer tokens, ramping stages, scenarios |
| `06_prometheus` | promtool | scrape configs, recording rules, error-ratio alerts, `histogram_quantile`, `up == 0` and `absent()` |
| `07_opentofu` | tofu | variables and outputs, `locals` and `for`, validation, `count` vs `for_each`, local modules |
| `08_caddy` | caddy | `respond` and env placeholders, static files with an SPA fallback, `reverse_proxy`, `handle_path` and `redir` |
| `09_cluster` | kind, kubectl | a live two-node cluster: create it, fix an image pull failure, a CrashLoopBackOff, and a Service with no endpoints |

49 exercises. Chapters 01, 03, 04, 06 and 07 run entirely offline and in well
under a second per check; the k6 checks take a few seconds each.

Chapter 09 works on a real cluster: the exercises tell you which `kubectl`
commands to run, and the checks read the cluster through the
`kind-opslings` context. It needs about 1.5 GB of RAM while it runs. When you
are done:

```sh
kind delete cluster --name opslings
```

The Docker exercises tag their images `opslings/<name>`. To clean up:
`docker image ls -q --filter 'reference=opslings/*' | xargs -r docker image rm`.

## Layout

```
exercises/      the directories you edit, one per exercise
solutions/      one reference solution per exercise, same shape
.templates/     pristine copies, used by `opslings reset`
checks/         one bash check per exercise (the spec), plus lib.sh helpers,
                fixtures, promtool tests and OpenTofu test files
scripts/        verify-all.sh: every solution passes, every untouched
                exercise fails
*.go            the runner (stdlib only)
```

## Adding an exercise

1. Create `exercises/<chapter>/<name>/` with the broken files. One of them
   opens with a comment block (title, concept, task, commands to try). It must
   fail its check as shipped: passing is what marks it done.
2. Copy it to `.templates/<chapter>/<name>/` and write the fixed version in
   `solutions/<chapter>/<name>/`.
3. Write `checks/<chapter>/<name>.sh`. It runs with bash, with the exercise
   directory as its working directory, and passes by exiting 0. Start it with

   ```bash
   #!/usr/bin/env bash
   # REQUIRES: helm yq
   # HINT
   # What to look at, in a few lines.
   source "$OPSLINGS_ROOT/checks/lib.sh"
   ```

   `REQUIRES` lists the tools the runner looks for before running the check.
   `lib.sh` has `fail`, `expect_eq`, `expect_yq`, `kubeval`, `scratch_copy`
   (for tools that write state), `start_target`, `caddy_start` and friends,
   and cleans up background processes when the check exits. Checks time out
   after 180 seconds.
4. Run `scripts/verify-all.sh`.

Ordering is by chapter directory, then natural sort of the exercise name
(`load2` before `load10`).

`opslings selftest` (what `verify-all.sh` calls) copies each solution and
each untouched template to a scratch directory and runs the check on
both. Chapters whose tools are not installed are reported `SKIPPED`, never
passed. The live-cluster checks in `09_cluster` only verify the files during
selftest.

## Other ways to learn

- [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) — build a cluster by hand, once, to know what all the pieces are
- [Killercoda](https://killercoda.com/) — free browser-based Kubernetes and Linux playgrounds, including CKA/CKAD scenarios
- [Kubernetes documentation: Tasks](https://kubernetes.io/docs/tasks/) — and `kubectl explain` for every field
- [Docker docs: Dockerfile reference](https://docs.docker.com/reference/dockerfile/) and [build best practices](https://docs.docker.com/build/building/best-practices/)
- [Helm chart template guide](https://helm.sh/docs/chart_template_guide/)
- [Grafana k6 documentation](https://grafana.com/docs/k6/latest/) — especially "Using k6" and the executor reference
- [PromLabs training](https://training.promlabs.com/) and [PromQL cheat sheet](https://promlabs.com/promql-cheat-sheet/)
- [OpenTofu documentation](https://opentofu.org/docs/) — the language section doubles as a Terraform tutorial
- [Caddy documentation](https://caddyserver.com/docs/) — read "Caddyfile concepts" and "directive order"
- [yq documentation](https://mikefarah.gitbook.io/yq/)
