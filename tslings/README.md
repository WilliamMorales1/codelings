# tslings

Small exercises to get you used to reading and writing **TypeScript** — and,
above all, to reading and responding to the type checker.

Shamelessly modelled on [rustlings](https://github.com/rust-lang/rustlings).
Every exercise is a `.ts` file (a few are small directories) that is broken
in some way. You fix it and save; once it passes it is marked done and the runner
moves you to the next one.

An exercise passes when **both**:

1. it typechecks under the strict [`tsconfig.json`](tsconfig.json) at the root
   (`strict`, `noUncheckedIndexedAccess`, `verbatimModuleSyntax`, …) — the same
   config your editor uses, so a red squiggle is a failure; and
2. its [vitest](https://vitest.dev) file in `tests/<chapter>/<name>.test.ts`
   passes. Many tests are partly or wholly *type-level*: `expectTypeOf(...)`
   assertions and `// @ts-expect-error` lines that must stay errors.

## Setup

You need Node.js 22.18 or newer (the runner is itself TypeScript, run by
Node's built-in type stripping) and npm:

```sh
sudo pacman -S nodejs npm          # Arch
sudo dnf install nodejs npm        # Fedora
brew install node                  # macOS
```

On Debian/Ubuntu the packaged Node is usually too old; use
[NodeSource](https://github.com/nodesource/distributions) or a version
manager such as [fnm](https://github.com/Schniz/fnm) or [nvm](https://github.com/nvm-sh/nvm)
(these work anywhere). Check with `node --version` (needs 22.18+).

Then install the three dev dependencies (TypeScript 7, vitest, @types/node):

```sh
git clone https://github.com/WilliamMorales1/codelings
cd codelings/tslings
npm install
node tslings.ts doctor
```

TypeScript 7 is the native (Go) compiler: checking an exercise takes a few
hundred milliseconds. Nothing is installed globally.

## Usage

```sh
node tslings.ts watch          # the main loop: re-checks every time you save
node tslings.ts                # check once, stop at the first unsolved exercise
node tslings.ts list           # every exercise and its status
node tslings.ts run tuples1    # typecheck + test one exercise by name
node tslings.ts hint tuples1   # print its hint
node tslings.ts solution tuples1
node tslings.ts reset tuples1  # back to the original, unsolved file
node tslings.ts watch 06       # only one chapter (or: watch type_level)
```

`npm run watch`, `npm run list` etc. do the same. Shorter still:

```fish
# fish
alias tslings 'node '(pwd)'/tslings.ts'
funcsave tslings
```

Open a second terminal with `tslings watch` running, edit the file it points
at, and save. Watch only re-checks exercises whose files changed.

Errors are shown as `file:line:col` with a code frame. The `File:` line and
each error location are terminal hyperlinks, so in a terminal that supports
OSC 8 (kitty, foot, WezTerm, Ghostty, recent VTE, iTerm2, Windows Terminal)
you can click them. Set `NO_COLOR=1` for plain output.

Use an editor with the TypeScript language server (VS Code, Neovim with
`ts_ls`/`vtsls`, Helix, Zed): hovering to see inferred types is half of
learning TypeScript.

## The exercises

| Chapter | What it covers |
| --- | --- |
| `00_intro` | the workflow, reading a compiler error |
| `01_basics` | annotations, inference and widening, unions, literal types, tuples, enums versus `as const` objects |
| `02_narrowing` | `typeof` / `in` / `instanceof`, discriminated unions, exhaustive `never` checks, type predicates, assertion functions |
| `03_objects` | optional and readonly properties, readonly arrays, index signatures, excess property checks, `satisfies`, `interface extends` versus `&` |
| `04_functions` | optional / default / rest parameters, overloads, `this` parameters, generic constraints, default type arguments, `const` type parameters |
| `05_utility_types` | `Partial`, `Pick`, `Omit`, `Record`, `ReturnType`, `Parameters`, `Awaited`, `NonNullable` |
| `06_type_level` | `keyof` / `typeof` / indexed access, conditional types, `infer`, mapped types, key remapping, template literal types, recursive types, a typed-dotted-paths challenge |
| `07_classes_modules` | class fields, `#private` versus `private`, abstract classes, `implements`, `import type`, module augmentation, writing a `.d.ts` for a JS module |
| `08_real_world` | validating `fetch` JSON from `unknown`, branded types, a `Result` type, a typed event emitter, a zod-style validator with `Infer<>` |

53 exercises. Chapters 00–05 are everyday TypeScript; `06_type_level` is
[type-challenges](https://github.com/type-challenges/type-challenges)
territory, easy to medium; `08_real_world` puts the pieces together in the
patterns you'll meet in production code.

## Layout

```
exercises/       the files you edit
solutions/       one reference solution per exercise
.templates/      pristine copies, used by `tslings reset`
tests/           one vitest file per exercise (the spec), with its hint
tsconfig.json    the strict config every exercise is checked against
tslings.ts       the runner, plus runner/: plain TypeScript, no runtime deps
scripts/         verify-all.sh: checks that every solution passes
                 and every exercise really is broken
```

The runner checks a batch of exercises with one `tsc` process (a generated
tsconfig that extends `tsconfig.json` and lists just those files) and one
vitest process, then attributes errors back to exercises by file.

## Adding an exercise

1. Write `tests/<chapter>/<name>.test.ts`. Import the exercise through the
   `@ex/` alias (`import { f } from '@ex/03_objects/foo1.ts'`) so the same test
   can be pointed at `solutions/`. Put the hint at the bottom in a
   `/* HINT ... */` block. Every test file needs at least one `it(...)`, even
   a type-only one.
2. Write `exercises/<chapter>/<name>.ts` (or a directory `<name>/`) with a
   header comment (title, concept, task), broken so it fails, and the fixed
   version under `solutions/`.
3. `cp -r exercises/<chapter>/<name>* .templates/<chapter>/`
4. `scripts/verify-all.sh` — it fails if a solution doesn't pass, if an
   untouched exercise already passes, or if
   `.templates/` has drifted from `exercises/`.

Ordering is by chapter, then natural sort of the name (`foo2` < `foo10`).
A `// @ts-expect-error` line that is also *executed* must not throw, or wrap
it in a function the test doesn't call (see `recursive1`).

## Other ways to learn TypeScript

- [The TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html) — the official reference; read "Narrowing" and "Type Manipulation" twice
- [type-challenges](https://github.com/type-challenges/type-challenges) — hundreds of type-level puzzles, easy to extreme, playable in the browser
- [Total TypeScript](https://www.totaltypescript.com/) — Matt Pocock's tutorials; the *Total TypeScript Essentials* book is free to read online
- [TypeScript Playground](https://www.typescriptlang.org/play) — try anything, see the emitted JS and the inferred types
- [Effective TypeScript](https://effectivetypescript.com/) — Dan Vanderkam's book of 83 specific ways to write better TypeScript
