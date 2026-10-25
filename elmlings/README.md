# elmlings

Small exercises to get you used to reading and writing **Elm**: values and types,
functions and pipelines, lists and pattern matching, records and custom types, Maybe and
Result instead of null and exceptions, Dict/Set/Array, JSON decoders, and the Elm
Architecture behind every Elm app.

Every exercise is one `.elm` module that doesn't compile yet, crashes on a `Debug.todo`,
or gives the wrong answer. You fix it and save. As soon as the checks in `checks/` pass, it
is done and the runner moves you on. Many exercises are about reading the compiler's error
messages, which are the friendliest of any language and much of what makes Elm worth
learning.

No prior Elm needed. Some programming in any language helps.

## Setup

Install the Elm compiler (0.19.1) and Node.js (the checks run in node):

```sh
sudo pacman -S nodejs        # Arch
sudo apt install nodejs      # Debian/Ubuntu
sudo dnf install nodejs      # Fedora
brew install elm node        # macOS (done, skip the next step)
```

```sh
curl -L https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz \
  | gunzip > ~/.local/bin/elm && chmod +x ~/.local/bin/elm
```

Then check:

```sh
./elmlings doctor
```

The first check downloads `elm/core`, `elm/json`, `elm/html` and `elm/browser` into
`~/.elm` (a few MB). After that everything works offline.

## Usage

```
./elmlings watch [CHAPTER]  # re-check on save, move on when it passes
./elmlings                  # the same, once (alias: verify)
./elmlings run [NAME]       # one exercise (default: the next unsolved one)
./elmlings hint [NAME]      # a nudge, then most of the answer
./elmlings list             # every exercise, DONE/PENDING, and the file to edit
./elmlings solution NAME    # the reference solution
./elmlings reset NAME       # restore the exercise from .templates/
./elmlings doctor           # are elm and node installed?
```

`NAME` can be `functions3`, `Functions3` or `02_functions/Functions3`. `CHAPTER` is a prefix
such as `02`. Passes are remembered in `.elmlings-progress` until you edit the file again.
File paths are clickable OSC 8 links; `NO_COLOR=1` turns colours and links off.

Elm has no runtime exceptions, with one deliberate hole: `Debug.todo "..."` compiles
anywhere and crashes when reached. The exercises use it to mark code you still have to write.

`elm repl` is handy for trying things out while you work.

## The exercises

| Chapter        | Covers                                                                                   |
| -------------- | ---------------------------------------------------------------------------------------- |
| 00_intro       | the loop, reading compiler errors                                                        |
| 01_values      | Int vs Float, converting numbers, strings, booleans, Char                                |
| 02_functions   | type annotations, partial application, `\x ->`, `\|>` pipelines, `>>` composition, `let` |
| 03_lists       | `::` and `++`, map and filter, foldl, `case` on lists, the List module                   |
| 04_types       | records, `{ r \| x = ... }`, custom types, variants with data, tuples                    |
| 05_maybe       | `Maybe.withDefault`, `case` on Maybe, `Maybe.map` and `andThen`, `List.filterMap`        |
| 06_result      | `Ok` and `Err`, `Result.andThen`, custom error types, `mapError`, `map2`                 |
| 07_recursion   | tail calls and accumulators, recursive types, avoiding recomputation                     |
| 08_collections | Dict, `Dict.update`, Set, Array                                                          |
| 09_json        | decoders, `map2` into records, optional and nested fields, encoders, `andThen` on a tag  |
| 10_tea         | model/view/update, adding a Msg, record models, `Browser.element` and `Cmd`              |

## Seeing it in a browser

The 10_tea exercises are real apps. After running one once (which creates the build
directory), compile it to a page and open it:

```sh
./elmlings run tea1
cd .elmlings-build && elm make ../exercises/10_tea/Tea1.elm --output=tea1.html
xdg-open tea1.html   # open on macOS
```

## Layout

```
exercises/<chapter>/<Name>.elm        what you edit
.templates/<chapter>/<Name>.elm       pristine copy, used by `reset`
solutions/<chapter>/<Name>.elm        reference solution
checks/<chapter>/<Name>Check.elm      hint and assertions; discovery is driven by these
checks/lib/Check.elm                  the helpers every check uses
scripts/harness.js                    runs compiled checks in node
scripts/verify-all.sh                 every solution passes, every untouched exercise fails
elmlings                              the runner (bash)
```

Elm wants module names capitalised and matching the file name, hence `Functions3.elm`.
The runner keeps one Elm project in `.elmlings-build/` whose `elm.json` lists every chapter
as a source directory. For each exercise it writes a `Main.elm` that imports the check,
compiles it with `elm make`, and runs the result in node, which prints each failed
assertion. Compiler errors point at your file. Anything running over 10 seconds is stopped.

## Adding an exercise

1. Write `solutions/<chapter>/<Name>.elm`: `module <Name> exposing (..)`, a `{- ... -}`
   comment block (title, what you learn, the task), then the working code. The name must be
   unique across the course.
2. Copy it to `exercises/` and `.templates/` and break it the way a real mistake would, or
   leave a `Debug.todo "..."`.
3. Write `checks/<chapter>/<Name>Check.elm`: `module <Name>Check exposing (failures)`, a
   `{- HINT ... -}` comment, `import Check` and `import <Name> exposing (..)`, then
   `failures = Check.all [ Check.eq "label" actual expected, ... ]`. Use `Check.float` for
   Floats. Never compare functions with `Check.eq`: Elm crashes on that.
4. Run `scripts/verify-all.sh`.

## Other ways to learn Elm

- [The official guide](https://guide.elm-lang.org/), short and the best place to start
- [Elm Koans](https://github.com/robertjlooby/elm-koans), fill-in-the-blank exercises run with elm-test
- [Exercism Elm track](https://exercism.org/tracks/elm)
- [Elm in Action](https://www.manning.com/books/elm-in-action), Richard Feldman's book
- [Beginning Elm](https://elmprogramming.com/), a free online book
- [Elm Radio](https://elm-radio.com/), a podcast on Elm idioms and tooling
