# leanlings

Small exercises to get you used to reading and writing **Lean 4** — including
reading and responding to compiler messages, and to unsolved proof goals.

Shamelessly modelled on [rustlings](https://github.com/rust-lang/rustlings).
Every exercise is a `.lean` file that does not compile yet. You fix it and save;
once it compiles cleanly it is marked done and the runner moves you on.

Exercises depend on the Lean **core library only** — no Mathlib, no downloads,
no waiting. A check of a single file takes well under a second.

## Setup

Install [elan](https://github.com/leanprover/elan), Lean's toolchain manager:

```sh
curl https://elan.lean-lang.org/elan-init.sh -sSf | sh   # Linux / macOS
brew install elan-init                                   # or, macOS
```

Then build the runner:

```sh
git clone https://github.com/WilliamMorales1/codelings
cd codelings/leanlings
lake build
```

`lean-toolchain` pins the version, so elan fetches the right Lean by itself.

## Usage

```sh
lake exe leanlings watch          # the main loop: re-checks every time you save
lake exe leanlings                # check once, stop at the first unsolved exercise
lake exe leanlings list           # every exercise and its status
lake exe leanlings run lists3     # check one exercise by name
lake exe leanlings hint lists3    # print its hint
lake exe leanlings solution lists3
lake exe leanlings reset lists3   # back to the original, unsolved file
```

Shorter, if you put the built binary on your `PATH`:

```sh
# fish
set -gx PATH $PWD/.lake/build/bin $PATH
leanlings watch
```

Open a second terminal with `leanlings watch` running, edit the file it points
at, and save. That is the whole workflow.

The `File:` line is a terminal hyperlink, so in a terminal that supports OSC 8
(kitty, foot, WezTerm, Ghostty, recent VTE, iTerm2, Windows Terminal) you can
click or ctrl-click it to open the current exercise in your editor. Set
`NO_COLOR=1` to get plain, unadorned output instead.

## The exercises

| Chapter | What it covers |
| --- | --- |
| `00_intro` | the workflow, `:=` versus `=` |
| `01_definitions` | `def`, type annotations, `let`, `#check` / `#eval`, namespaces |
| `02_functions` | parameters, lambdas, partial application, implicit arguments, higher-order functions |
| `03_structures` | fields, constructors, `with` updates, `deriving` |
| `04_inductive` | enumerations, constructors with data, `Option`, recursion on `Nat`, trees |
| `05_lists` | `::` and `++`, `map`, `filter`, `foldl`, hand-written recursion |
| `06_typeclasses` | `ToString`, `BEq`, operator classes, instance arguments, your own class |
| `07_monads` | `IO` and `do`, `Option` and `Except` as monads, `let mut` / `for`, `mapM` |
| `08_propositions` | propositions as types, implication, `∧` / `∨`, `∀` / `∃` |
| `09_proofs` | `rfl`, `intro` / `exact`, `simp`, `induction`, `cases`, `calc` |
| `10_tactics` | `rw`, `omega`, `constructor`, `apply`, `decide` |

51 exercises. The first half is ordinary functional programming; from
`08_propositions` on you are writing proofs, which is the part of Lean no other
language will teach you.

## Layout

```
exercises/      the files you edit
solutions/      one reference solution per exercise
.templates/     pristine copies, used by `leanlings reset`
Leanlings/      the runner, itself written in Lean
scripts/        verify-all.sh: checks that every solution compiles
                and every exercise really is broken
```

## Adding an exercise

Drop a `.lean` file into the right `exercises/<chapter>/` directory, add a
matching file under `solutions/` and `.templates/`, and run
`scripts/verify-all.sh`. Ordering is alphabetical, by chapter and then by
filename, which is why the names are numbered.

Give it a `/- HINT ... -/` block at the bottom; that is where
`leanlings hint` reads from.

## Other ways to learn Lean

- [Functional Programming in Lean](https://lean-lang.org/functional_programming_in_lean/) — the book for the programming half
- [Theorem Proving in Lean 4](https://lean-lang.org/theorem_proving_in_lean4/) — the book for the proving half
- [Mathematics in Lean](https://leanprover-community.github.io/mathematics_in_lean/) — once you want Mathlib
- [The Natural Number Game](https://adam.math.hhu.de/#/g/leanprover-community/nng4) — proofs, in a browser, from zero
