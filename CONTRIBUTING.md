# Contributing

Shared conventions for every course. Every course in `codelings/` follows the same shape, modelled on rustlings and on
`leanlings/` (the reference implementation — read its README and runner first).

## Layout

```
<name>lings/
  README.md          setup, usage, chapter table, layout, "adding an exercise", "other ways to learn"
  exercises/<NN_chapter>/<exercise>[.<ext>|/]   what the learner edits (a file OR a directory)
  solutions/<NN_chapter>/<exercise>...          reference solution, same shape
  .templates/<NN_chapter>/<exercise>...         pristine copy of exercises/, used by `reset`
  checks/ or tests/<NN_chapter>/<exercise>.*    the spec: one per exercise; discovery is driven by these files
  scripts/verify-all.sh                          every solution passes AND every untouched exercise fails
  <runner source>
  .gitignore
```

- Chapters `00_intro` .. `NN_*`; ordering = chapter dir name, then natural sort of exercise name (`docker2` < `docker10`).
- Exercise name = file stem / dir name, unique across the course.
- `00_intro/intro1`: one tiny, obvious fix; teaches the loop (keep `watch` running, fix, save, it moves on).

## Done = passes

There is no `I AM NOT DONE` marker. An exercise is done as soon as its check passes, so every
exercise (intro1 included) must fail its check as shipped; `verify-all.sh` enforces that.
Runners remember passes in a git-ignored `.<x>lings-progress[.json]` keyed by the exercise's
file stamp (mtime+size), so `list` is instant and editing a solved exercise re-queues it.
The `File:` line points at the first file whose template differs from the solution.
Exercise files open with a comment block: title, what to learn, the task, and how to run
anything manual.

Exception: an exercise whose goal can't be checked by running it (a pure refactor) may keep
a marker line; runners that support it (clings) treat a marker as "not done yet".

## Hints

Hint lives in the check/test file, not the exercise, in a block the runner extracts:
- shell: a `# HINT` line followed by `#`-prefixed lines, ends at first non-`#` line
- JS: `/* HINT ... */`
- OCaml: `(* HINT ... *)`
- Elm: `{- HINT ... -}`

## Runner CLI (identical verbs across courses)

```
<x>lings [verify]        check in order, stop at first unsolved (default)
<x>lings watch [CHAPTER] re-check on save (poll mtime+size, ~700ms); optional chapter prefix filter
<x>lings run [NAME]      one exercise (default: next unsolved)
<x>lings hint [NAME]
<x>lings list            every exercise + PENDING/FAILED/DONE + progress bar
<x>lings solution NAME   print reference solution (all files if directory)
<x>lings reset NAME      restore from .templates/
<x>lings doctor          required external tools, which are missing, install command
<x>lings help
```

Output style copied from leanlings: `v chapter/name passes!` (green), `x ... fails` (red) with
indented check output + hint, PENDING (yellow) in `list`, `Progress: [####----] n/N`,
`File:` line as OSC 8 hyperlink, `NO_COLOR` disables colour + hyperlinks, clear screen per
watch refresh. Watch caches pass/fail in memory keyed by file stamps and only re-runs
exercises whose files changed. Find project root by walking up to a dir containing `exercises/`.

## Quality bar

- Each exercise teaches one idea, broken in a way that reads like a real mistake or a clear TODO.
- Checks assert intent (the actual behaviour/fields), not just "parses".
- Laptop-friendly: small images (alpine/busybox), no heavy VMs, offline after first install where possible.
- `scripts/verify-all.sh` must pass for every chapter whose tools are available; chapters whose tools are
  missing are reported SKIPPED, never silently passed.
- Code comments: only non-obvious why.

## Imported courses

Cloned from upstream and retrofitted with the runner verbs above (verify/watch/run/hint/list/
solution/reset/doctor, `File:` OSC 8 links, `NO_COLOR`, progress bar, root walk-up), each in its
own language so the course needs nothing extra:

| dir | upstream | runner |
|---|---|---|
| `ziglings/` | codeberg.org/ziglings/exercises | `zig build <verb> [-Dn=N]` (Elrond, `rivendell/elrond.zig`) |
| `dockerlings/` | github.com/furkan/dockerlings | Go/cobra; `watch` is the Bubble Tea TUI, re-checks on save |
| `golings/` | github.com/mauricioabreu/golings | Go/cobra; no solutions upstream |
| `erlings/` | github.com/lambdaclass/erlings | `./erlings` escript; done = tests pass, cached in `.erlings-progress` |
| `exlings/` | github.com/zoedsoupe/exlings | Elixir script `./exlings`; checks in `checks/` (hint + expected output), solutions added |
| `haskellings/` | github.com/MondayMorningHaskell/haskellings | Haskell (stack, lts-18.4 / GHC 8.10.4) |
| `clings/` | github.com/danwritecode/clings | C; default verb is the original watch loop |
| `nimlings/` | github.com/sergiotapia/nimlings | Nim (`src/nimlings.nim`); exercises moved to `exercises/` |
| `nixlings/` | github.com/spacekookie/nixlings | bash `./nixlings`; checks in `checks/`, solutions in `solutions/` |

`cplings/` (github.com/rdjondo/cplings) is imported as-is, with its original CMake runner (`cd build && make`).
`rustlings/` (github.com/rust-lang/rustlings) is the output of `rustlings init` v6.5.0, run with the upstream `rustlings` binary.

Upstream-only quirks kept: ziglings tracks progress in `.progress.txt`, dockerlings in
`.dockerlings/progress.json`, erlings in `.erlings-progress`.
