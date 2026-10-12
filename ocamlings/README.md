# ocamlings

Small exercises to get you used to reading and writing **OCaml**: values and types,
functions and currying, lists and pattern matching, records and variants, option and
result, modules and functors, and the imperative corner (refs, arrays, hash tables).

Every exercise is one `.ml` file that doesn't compile yet, raises, or gives the wrong
answer. You fix it and save. As soon as the checks in `checks/` pass, it is done and the
runner moves you on. Many exercises are about reading the compiler's error messages,
which are much of what makes OCaml worth learning.

No prior OCaml needed. Some programming in any language helps.

## Setup

Install OCaml (just the compiler; no opam, dune or packages needed):

```sh
sudo pacman -S ocaml        # Arch
sudo apt install ocaml      # Debian/Ubuntu
sudo dnf install ocaml      # Fedora
brew install ocaml          # macOS
```

Then check:

```sh
./ocamlings doctor
```

Each exercise runs in the `ocaml` toplevel, so there is no build step. Tested with OCaml
5.5; 4.14 is the oldest release with every library function the course uses.

## Usage

```
./ocamlings watch [CHAPTER]  # re-check on save, move on when it passes
./ocamlings                  # the same, once (alias: verify)
./ocamlings run [NAME]       # one exercise (default: the next unsolved one)
./ocamlings hint [NAME]      # a nudge, then most of the answer
./ocamlings list             # every exercise, DONE/PENDING, and the file to edit
./ocamlings solution NAME    # the reference solution
./ocamlings reset NAME       # restore the exercise from .templates/
./ocamlings doctor           # is ocaml installed?
```

`NAME` can be `functions3` or `02_functions/functions3`. `CHAPTER` is a prefix such as
`02`. Passes are remembered in `.ocamlings-progress` until you edit the file again. File
paths are clickable OSC 8 links; `NO_COLOR=1` turns colours and links off.

Two compiler warnings are errors here: a `match` that misses a case (8) and a case that
can never be reached (11). Real projects usually do the same.

`utop` (or plain `ocaml`) is handy for trying things out while you work.

## The exercises

| Chapter | Covers |
|---|---|
| 00_intro | the loop, reading compiler errors |
| 01_values | ints vs floats, conversions, strings, booleans and equality, chars |
| 02_functions | defining, several arguments, partial application, `fun`, `let rec`, labelled and optional arguments, `\|>` |
| 03_lists | literals, `::` and `@`, matching on lists, the List module |
| 04_patterns | exhaustiveness, guards, tuples and case order, `function` and or-patterns |
| 05_types | records, `{ r with ... }`, variants, recursive and polymorphic types |
| 06_errors | option, `_opt` functions, result, exceptions, `let*` |
| 07_recursion | accumulators and tail calls, mutual recursion, avoiding recomputation |
| 08_modules | modules, signatures, Map.Make, writing a functor |
| 09_imperative | refs, mutable fields, arrays and `for`, Hashtbl, `while` and Buffer |
| 10_higher_order | composition, fold_left vs fold_right, closures, lazy Seq |
| 11_strings | Printf, splitting, immutable strings |

## Layout

```
exercises/<chapter>/<name>.ml   what you edit
.templates/<chapter>/<name>.ml  pristine copy, used by `reset`
solutions/<chapter>/<name>.ml   reference solution
checks/<chapter>/<name>.ml      hint and assertions; discovery is driven by these
checks/lib.ml                   the Check helpers every check uses
scripts/verify-all.sh           every solution passes, every untouched exercise fails
ocamlings                       the runner (bash)
```

The runner joins `checks/lib.ml`, your exercise and its check into one toplevel script
(with line directives, so errors still point at your file) and runs it with `ocaml`,
stopping it after 10 seconds.

## Adding an exercise

1. Write `solutions/<chapter>/<name>.ml`: a comment block (title, what you learn, the
   task), then the working code.
2. Copy it to `exercises/` and `.templates/` and break it the way a real mistake would, or
   leave a `failwith "TODO"`.
3. Write `checks/<chapter>/<name>.ml`: a `(* HINT ... *)` comment, then `let () = ...`
   calling `Check.int`, `Check.str`, `Check.ints`, `Check.opt` and friends from
   `checks/lib.ml`. Never write `( * )` or a parenthesis followed by a star inside a
   comment: it opens or closes the comment.
4. Run `scripts/verify-all.sh`.

## Other ways to learn OCaml

- [OCaml.org tutorials](https://ocaml.org/docs), the official getting-started path
- [OCaml Programming: Correct + Efficient + Beautiful](https://cs3110.github.io/textbook/), Cornell's CS 3110 textbook
- [Real World OCaml](https://dev.realworldocaml.org/), the practical book
- [Exercism OCaml track](https://exercism.org/tracks/ocaml)
- [Learn-OCaml exercises](https://ocaml-sf.org/learn-ocaml-public/), graded in the browser
- [99 OCaml problems](https://ocaml.org/exercises)
