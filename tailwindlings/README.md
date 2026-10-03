# tailwindlings

Small exercises to get you used to reading and writing **Tailwind CSS v4**:
utilities, variants, responsive design, dark mode, and the CSS-first
configuration (`@theme`, `@utility`, `@custom-variant`, `@source`).

Shamelessly modelled on [rustlings](https://github.com/rust-lang/rustlings).
Every exercise is an HTML file (sometimes a directory with a `style.css`) whose
styling is wrong or missing. You fix it and save; once the tests pass the
exercise is done and the runner moves you to the next one.

The checks do not grep for class names. Each one compiles your exercise with
Tailwind's own compiler (the same scanner + compiler + Lightning CSS pipeline
the CLI uses), loads the HTML, and asks what style an element actually ends up
with, at a given viewport width, colour scheme, or hover/focus state. So any
correct solution passes, not just the one in `solutions/`.

## Setup

You need Node.js 22.12 or newer, and npm:

```sh
sudo pacman -S nodejs npm          # Arch
sudo dnf install nodejs npm        # Fedora
brew install node                  # macOS
```

On Debian/Ubuntu the packaged Node is usually too old; use
[NodeSource](https://github.com/nodesource/distributions) or a version
manager such as [fnm](https://github.com/Schniz/fnm) or [nvm](https://github.com/nvm-sh/nvm)
(these work anywhere). Check with `node --version` (needs 22.12+).

Then install the course's dependencies (Tailwind, vitest, jsdom, postcss; all
local to this directory, nothing global):

```sh
git clone https://github.com/WilliamMorales1/codelings
cd codelings/tailwindlings
npm install
node tailwindlings.js doctor
```

After `npm install` everything runs offline.

## Usage

```sh
node tailwindlings.js watch          # the main loop: re-checks every time you save
node tailwindlings.js                # check once, stop at the first unsolved exercise
node tailwindlings.js list           # every exercise and its status
node tailwindlings.js run flex1      # check one exercise by name
node tailwindlings.js hint flex1     # print its hint
node tailwindlings.js solution flex1
node tailwindlings.js reset flex1    # back to the original, unsolved file
node tailwindlings.js preview flex1  # serve it in a browser with its compiled CSS
```

The same verbs are wired up as npm scripts: `npm run watch`,
`npm run preview flex1`, `npm run hint flex1` ...

Open a second terminal with `watch` running, edit the file it points at, and
save. `watch 04` (or `watch responsive`) limits it to one chapter.

`preview` starts a small server on a free port (set `PORT` to pick one),
compiles the exercise on every request and reloads the page when you save.
For dark-mode and reduced-motion exercises use your browser's devtools
(Rendering panel: "Emulate CSS media feature ...").

The `File:` line is a terminal hyperlink (OSC 8). Set `NO_COLOR=1` for plain
output.

## The exercises

| Chapter | What it covers |
| --- | --- |
| `00_intro` | the workflow, how unknown classes fail silently |
| `01_utilities` | spacing, colours and `/opacity`, typography, sizing, borders and radius, shadows and rings |
| `02_layout` | flexbox, `flex-col` / `flex-1`, grid and spans, positioning and `z-*`, `container`, centring |
| `03_states` | `hover:` / `focus:` / `active:`, `group-*`, `peer-*`, `disabled:` and `aria-*`, `data-*`, `odd:` / `not-last:` |
| `04_responsive` | mobile first, stacked breakpoints, `max-*` ranges, container queries (`@container`, `@md:`) |
| `05_dark_mode` | `dark:`, class-based dark via `@custom-variant`, data-attribute themes and stacked variants |
| `06_theme` | `@theme` colours, fonts and breakpoints, resetting a namespace, arbitrary values, `bg-(--var)`, `@source inline()` |
| `07_components` | `@utility`, functional utilities with `--value()`, `@apply` in `@layer components`, layer precedence, form controls |
| `08_polish` | transitions, custom animations, `sr-only` / `focus-visible:`, `motion-safe:` / `motion-reduce:`, truncation and text polish |

43 exercises. The first half is utilities and variants you will type every
day; from `06_theme` on you are configuring Tailwind itself in CSS.

## Layout

```
exercises/      the files you edit
solutions/      one reference solution per exercise
.templates/     pristine copies, used by `reset`
tests/          one vitest file per exercise (the spec, and the hint)
  helpers.js    load(): compile an exercise and query resolved styles
  cascade.js    a small CSS cascade (layers, @media, @container, var(), specificity)
runner/         the CLI: discovery, vitest driver, Tailwind build, preview server
scripts/        verify-all.sh: every solution passes, every exercise really fails
```

jsdom's own `getComputedStyle` ignores `@layer`, `@media`, `@container` and
`var()`, which is most of what Tailwind v4 emits, so `tests/cascade.js`
resolves the cascade itself. A test picks the environment:

```js
const page = await load('04_responsive/responsive2');
page.get('#products', 'grid-template-columns', { width: 375 });
page.num('#card', 'padding-left');                       // px
page.get('#btn', 'background-color', { hover: '#btn', scheme: 'dark' });
page.theme('--color-sky-600');                            // theme value, to compare against
```

It models what Tailwind output needs (layers, specificity, inheritance,
registered `@property` initial values, state pseudo-classes, media and container
queries). It does not do layout: tests assert the styles that produce a layout,
not pixel positions.

## Adding an exercise

1. Write the finished version in `solutions/<chapter>/<name>.html` (or a
   `<name>/` directory with `index.html` + `style.css`). Open it with a comment
   block: title, concept, task, and the `preview` command.
2. Copy it to `exercises/` and `.templates/`, break it the way a real person
   would, so its tests fail as shipped.
3. Add `tests/<chapter>/<name>.test.js` using `load()` from `tests/helpers.js`,
   and a `/* HINT ... */` block at the bottom.
4. Run `scripts/verify-all.sh` (or `scripts/verify-all.sh 04` for one chapter).

Single-file exercises only scan their own file (`@source "./name.html"`), so
classes in one exercise never leak into another's CSS. Remember that the
scanner reads comments too: a class named in the header comment gets
generated, although it only applies if an element actually uses it.

## Other ways to learn Tailwind

- [tailwindcss.com/docs](https://tailwindcss.com/docs): the reference; every utility page shows the CSS it emits
- [Tailwind Play](https://play.tailwindcss.com): an online playground, handy for "what does this class compile to?"
- [Upgrade guide](https://tailwindcss.com/docs/upgrade-guide): what changed from v3 (useful when reading older tutorials)
- [CSS Battle](https://cssbattle.dev): sharpen the plain CSS that every utility is made of
- [MDN CSS](https://developer.mozilla.org/docs/Web/CSS): for the properties behind the classes
