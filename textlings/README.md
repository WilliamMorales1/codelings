# textlings

Small exercises to get you fluent in **jq** and **awk**, and in the shell
pipelines that glue them to `sort`, `uniq`, `cut` and `diff`.

Shamelessly modelled on [rustlings](https://github.com/rust-lang/rustlings).
Every exercise is a directory with some realistic input (`kubectl -o json`,
GitHub API responses, npm lockfiles, nginx access logs, `journalctl -o json`,
`ps aux`, `df -P`, `/etc/passwd`, CSV exports, `pacman -Qi`) and one program
you write:

- `filter.jq`, run as `jq $(cat flags) -f filter.jq INPUT`
- `prog.awk`, run as `awk -f prog.awk INPUT`
- `pipeline.sh`, run as `bash pipeline.sh INPUT`

Make its output match `expected.txt` and save; once the check passes the
exercise is done and the runner moves you on. The check also runs your program on a second,
hidden input, so hard-coding the answer does not pass.

## Setup

```sh
sudo pacman -S jq gawk go              # Arch
sudo apt install jq gawk golang        # Debian/Ubuntu
sudo dnf install jq gawk golang        # Fedora
brew install jq gawk go coreutils      # macOS (checks need GNU `timeout`)
```

If your package manager's Go is older than 1.27, get it from [go.dev/dl](https://go.dev/dl/).
Optional: the one true awk, used by `scripts/verify-all.sh` (Arch `nawk`,
Debian/Ubuntu `original-awk`). If it isn't installed as `nawk`, point to it
with `NAWK=/path/to/awk`.

jq 1.7 or newer is required (`pick`, `ltrimstr`/`trim` and friends); the
course is written against jq 1.8.2. gawk 5.x is required; any version since
4.0 handles the gawk-only exercises.

Build the runner:

```sh
git clone https://github.com/WilliamMorales1/codelings
cd codelings/textlings
go build -o textlings .
```

## Usage

```sh
./textlings watch           # the main loop: re-checks every time you save
./textlings                 # check once, stop at the first unsolved exercise
./textlings list            # every exercise and its status
./textlings run awk3        # check one exercise by name
./textlings hint awk3       # print its hint
./textlings solution awk3   # the reference program (not the data)
./textlings reset awk3      # back to the original, unsolved files
./textlings doctor          # which tools are installed, and how to get the rest
./textlings watch 05        # only chapter 05
```

Open a second terminal with `textlings watch` running, edit the file it
points at, and save. Run the program by hand from the exercise directory as
often as you like; the header comment of every exercise says how.

The `File:` line is a terminal hyperlink (OSC 8), so in kitty, foot, WezTerm,
Ghostty, recent VTE or iTerm2 you can click it. `NO_COLOR=1` gives plain
output.

A failing check shows the command it ran and a diff: `-` lines are what was
expected, `+` lines are yours. Trailing blanks and trailing empty lines are
ignored; everything else counts. Checks run with `LC_ALL=C`, so `sort` orders
by bytes.

## POSIX awk first

Chapters 04 to 07 teach POSIX awk and check it with `gawk --posix`, which
rejects gawk extensions, so what you write there runs on mawk, busybox, BSD
awk and the one true awk as well. The gawk-only features are in their own,
clearly marked exercises (`awkadv5` to `awkadv7`) and run under plain `gawk`:

| gawk only | POSIX way |
| --- | --- |
| `FPAT`, `--csv` (gawk 5.3+, also the one true awk 2nd ed.) | careful `split`, or a real CSV tool |
| `PROCINFO["sorted_in"]`, `asort`, `asorti` | `print ... \| "sort"` and `close()` |
| `gensub` with `\1` backreferences | `match()` + `RSTART`/`RLENGTH` + `substr` |
| `@include "lib.awk"`, the `func` keyword, `**` | paste the function in; `function`; `^` |

## The exercises

| Chapter | What it covers |
| --- | --- |
| `00_intro` | the workflow |
| `01_jq_basics` | `.field`, `.[]`, pipes and commas, `-r` / `-c`, `?`, `//`, indexes and `length` |
| `02_jq_construct` | object and array construction, `map`, `add`, `select`, `to_entries` / `from_entries` / `with_entries`, string interpolation, `@csv` / `@tsv`, `@base64d` / `@sh`, `pick` (1.7+) |
| `03_jq_advanced` | `group_by` / `sort_by`, `unique`, `reduce`, `foreach`, `-n` + `inputs`, `--slurp` + `limit`, `del`, `paths` / `getpath`, `walk`, `\|=` / `+=` / `*=`, `--arg` / `--argjson` / `$ENV`, `def`, `try` / `catch` / `error` |
| `04_awk_basics` | fields, `FS`, `NR` / `NF` / `$NF`, `printf`, `BEGIN` / `END` |
| `05_awk_logic` | comparison patterns (strings versus numbers), `~` / `!~`, `if` / `else`, range patterns, `next` |
| `06_awk_data` | associative arrays, counting and grouping, `split`, string functions, `FNR == NR` joins, `$1 = $1` and `OFS`, `-v` |
| `07_awk_advanced` | functions, a `printf` report through `sort` with `close()`, paragraph mode `RS = ""`, `getline` done safely; gawk: `FPAT`, `PROCINFO["sorted_in"]`, `gensub` |
| `08_pipelines` | top-N from an access log, JSON log to TSV report, diffing two API responses, jq + awk + sort together |

58 exercises.

## Layout

```
exercises/<chapter>/<name>/   what you edit: input data, expected.txt, your program (and flags for jq)
solutions/<chapter>/<name>/   the same directory, solved
.templates/                   pristine copies of exercises/, used by `textlings reset`
checks/<chapter>/<name>.sh    the spec: runs your program, compares output; its # HINT block is the hint
checks/<chapter>/fixtures/    the hidden second inputs and their expected output
checks/lib.sh                 expect_out, must_use and friends
scripts/verify-all.sh         every solution passes, every untouched exercise fails (also under nawk)
scripts/record.sh             maintainer tool: fill in expected outputs from the solutions
*.go                          the runner (standard library only)
```

## Adding an exercise

1. `exercises/<chapter>/<name>/`: the input file(s), the broken program with
   a header comment (title, concept, task), failing its check as shipped, and
   a `flags` file for jq if it needs flags.
2. `solutions/<chapter>/<name>/`: the solved program (and `flags`). The rest
   is copied over by `scripts/record.sh`.
3. `checks/<chapter>/fixtures/<name>/`: a second input with the same file
   name, different enough that hard-coding fails.
4. `checks/<chapter>/<name>.sh`:

   ```bash
   #!/usr/bin/env bash
   # REQUIRES: gawk
   # HINT
   # What to look at, then the fix.
   source "$TEXTLINGS_ROOT/checks/lib.sh"

   expect_out awk expected.txt -- access.log
   expect_out --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/access.log"
   ```

   The kinds are `jq`, `awk` (POSIX, via `gawk --posix`), `gawk` and `sh`.
   `--sort` compares sorted output, for awk's unordered `for (k in a)`.
5. `scripts/record.sh <chapter>` writes the missing `expected.txt` files from
   the solution. Read them. Then `scripts/verify-all.sh`.

## Other ways to learn

- [The jq manual](https://jqlang.org/manual/) and [jqplay](https://play.jqlang.org/), a jq playground in the browser
- [The AWK Programming Language, 2nd edition](https://awk.dev/) (Aho, Kernighan, Weinberger, 2023): short, and still the best awk book
- [The GNU Awk User's Guide](https://www.gnu.org/software/gawk/manual/), for everything gawk adds
- [Grymoire's awk tutorial](https://www.grymoire.com/Unix/Awk.html)
- `man 1p awk`: the POSIX spec, for what is portable
