> **Imported from [github.com/zoedsoupe/exlings](https://github.com/zoedsoupe/exlings)** (commit `f8c6e67`) by zoedsoupe and contributors, under the Apache-2.0 license (see [LICENSE](LICENSE)).
> Changes in this copy: exercises split into chapters under `exercises/`, hints and expected output moved to `checks/`, reference solutions added, `mix exlings` replaced by a standalone `./exlings` script with the shared verbs. The pt-BR translation was not imported. All credit for the course itself goes to the original authors.

# exlings

Small exercises to get you used to reading and writing [Elixir](https://elixir-lang.org/).
Each one is a short script with a `???` to fill in (or a bug to fix). Fix it, save, and the
runner moves you on. No prior Elixir or Erlang needed.

## Setup

Install Elixir (it pulls in Erlang/OTP):

```sh
sudo pacman -S elixir        # Arch
sudo apt install elixir      # Debian/Ubuntu
sudo dnf install elixir      # Fedora
brew install elixir          # macOS
```

Then check:

```sh
./exlings doctor
```

No `mix deps.get` and no build step: `./exlings` is a plain Elixir script.

## Usage

```
./exlings watch [CHAPTER]  # re-check on save, move on when it passes
./exlings                  # the same, once (alias: verify)
./exlings run [NAME]       # one exercise (default: the next unsolved one)
./exlings hint [NAME]      # hints, from a nudge to almost the answer
./exlings list             # every exercise, DONE/PENDING, and the file to edit
./exlings solution NAME    # the reference solution
./exlings reset NAME       # restore the exercise from .templates/
./exlings doctor           # elixir, erl and their versions
```

`NAME` can be `001_hello_world`, `hello_world`, `00_intro/hello_world` or just `1`.
An exercise is done when it runs cleanly and prints exactly the expected output (the last
one is done when its ExUnit tests pass). Passes are remembered in `.exlings-progress` until
you edit the file again. File paths are clickable OSC 8 links; `NO_COLOR=1` turns colours
and links off.

Hints are ordered: the first asks you to predict or try something in `iex`, later ones get
closer to the answer. Read them one at a time.

## The exercises

| Chapter | Covers |
|---|---|
| 00_intro | printing, comments, variables |
| 01_values | math, strings, atoms, booleans, numbers |
| 02_data_structures | tuples, lists, pattern matching, list patterns |
| 03_patterns | `_`, the pin operator, nested patterns |
| 04_functions | named functions, multiple clauses, guards, `fn`, `&` capture |
| 05_control_flow | `case`, `cond`, `if`/`unless`, the pipe |
| 06_maps_structs | maps, keyword lists, structs |
| 07_enum | map, filter, reduce, each, find, all?/any?, sort, group_by |
| 08_recursion | base cases, list recursion, accumulators, tail calls |
| 09_comprehensions | `for`, filters, multiple generators |
| 10_strings | String module, interpolation, binaries, charlists |
| 11_ranges_streams | ranges, lazy streams |
| 12_modules | nesting, `alias`, `import`, `defp`, module attributes |
| 13_io_files | IO, File, streaming files, Path, `IO.inspect` |
| 14_errors | error tuples, raise/rescue, try/after, throw/catch, `with` |
| 15_protocols | built-in protocols, `defimpl`, Enumerable |
| 16_behaviours | `@callback`, dispatch, generic code over behaviours |
| 17_sigils | `~r`, `~s`/`~S`/`~w`, `~D`/`~T` |
| 18_testing | ExUnit |

## Layout

```
exercises/<chapter>/<NNN_name>.ex   what you edit
.templates/<chapter>/<NNN_name>.ex  pristine copy, used by `reset`
solutions/<chapter>/<NNN_name>.ex   reference solution
checks/<chapter>/<NNN_name>.exs     hints + expected output; discovery is driven by these
scripts/verify-all.sh               every solution passes, every untouched exercise fails
exlings                             the runner
```

## Adding an exercise

1. Write `exercises/<chapter>/<NNN_name>.ex`: a comment block (title, what you learn, the
   task), then code with `???` where the learner works. It must fail as shipped.
2. Copy it to `.templates/` and write the fixed version in `solutions/`.
3. Write `checks/<chapter>/<NNN_name>.exs`: a `# HINT` block of `#` lines, then a map,
   `%{expected_output: "..."}`, `%{expected_output: nil}` (any clean run passes) or
   `%{kind: :exunit}`.
4. Run `scripts/verify-all.sh`.

## Other ways to learn Elixir

- [Elixir getting started guide](https://hexdocs.pm/elixir/introduction.html)
- [Exercism Elixir track](https://exercism.org/tracks/elixir)
- [Elixir Koans](https://github.com/elixirkoans/elixir-koans)
- [Elixir School](https://elixirschool.com/en)
- [Elixir in Action](https://www.manning.com/books/elixir-in-action-third-edition) by Saša Jurić
