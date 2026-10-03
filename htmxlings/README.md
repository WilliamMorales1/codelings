# htmxlings

Small exercises to get you used to building pages with **htmx**: requests
from attributes, HTML fragments from the server, swaps, triggers, response
headers, and the classic hypermedia patterns.

Shamelessly modelled on [rustlings](https://github.com/rust-lang/rustlings).
Every exercise is a directory with an `index.html` page and usually a
`handlers.js` file holding the server routes that page talks to. Something
in one of them is broken or missing. You fix it and save;
once the tests pass the exercise is done and the runner moves you on.

The tests are real: each one serves the exercise over HTTP with a tiny
built-in server, loads the page into [jsdom](https://github.com/jsdom/jsdom)
with the real htmx library running in it, clicks and types, and checks
what htmx swapped in. They also call your handlers over HTTP and check the
fragments and `HX-*` headers they return.

The course targets **htmx 2.0.11** (npm `latest`). htmx 4.0 shipped in
August 2026 under the npm tag `next`, with a rewritten core and changed
defaults; the htmx.org examples and the Hypermedia Systems book still
describe 2.x, and so does this course.

## Setup

You need Node.js 22.13 or newer and npm:

```sh
sudo pacman -S nodejs npm          # Arch
sudo dnf install nodejs npm        # Fedora
brew install node                  # macOS
```

On Debian/Ubuntu the packaged Node is usually too old; use
[NodeSource](https://github.com/nodesource/distributions) or a version
manager such as [fnm](https://github.com/Schniz/fnm) or [nvm](https://github.com/nvm-sh/nvm)
(these work anywhere). Check with `node --version` (needs 22.13+).

Then install the course's dependencies (htmx, the json-enc extension,
vitest and jsdom; nothing global, no browser download):

```sh
git clone https://github.com/WilliamMorales1/codelings
cd codelings/htmxlings
npm install
node htmxlings.js doctor
```

## Usage

```sh
node htmxlings.js watch          # the main loop: re-checks every time you save
node htmxlings.js                # check once, stop at the first unsolved exercise
node htmxlings.js list           # every exercise and its status
node htmxlings.js run swap1      # check one exercise by name
node htmxlings.js hint swap1     # print its hint
node htmxlings.js solution swap1
node htmxlings.js reset swap1    # back to the original, unsolved files
npm run serve swap1              # try it in a real browser (http://127.0.0.1:3000)
```

The `npm run` forms work too: `npm run watch`, `npm run hint -- swap1`.

`serve` opens the exercise in your browser via `xdg-open` (set `NO_OPEN=1`
to skip that, `PORT=8080` to change the port) and logs every request, with
htmx ones marked. `handlers.js` is re-imported whenever you save it, so a
refresh is enough. Use the browser's devtools Network tab to watch the
`HX-*` headers go back and forth.

Open a second terminal with `watch` running, edit the files it points at,
and save. The `File:` line is a terminal hyperlink (OSC 8); set
`NO_COLOR=1` for plain output.

## The exercises

| Chapter | What it covers |
| --- | --- |
| `00_intro` | the workflow, how pages and handlers fit together |
| `01_basics` | `hx-get` / `hx-post`, `hx-target` and its extended selectors, `hx-swap` modes, returning fragments |
| `02_triggers` | `hx-trigger` with `changed`, `delay`, `throttle`, `once`, `load`, `every`, event filters, `from:` |
| `03_forms` | `hx-post` forms, `hx-include`, `hx-vals`, validation errors as HTML, 422 + `responseHandling`, `hx-delete` + `hx-confirm` |
| `04_swapping` | `outerHTML` vs `innerHTML`, `hx-swap-oob`, `hx-select`, swap delays and `htmx-swapping` |
| `05_headers` | `HX-Request` on the server, `HX-Trigger`, `HX-Redirect`, `HX-Retarget` / `HX-Reswap`, `hx-headers` |
| `06_patterns` | active search, infinite scroll, click to edit, delete row, lazy loading, progress polling with 286 |
| `07_navigation` | `hx-boost`, `hx-push-url`, deep links, history restores and `Vary: HX-Request` |
| `08_events_extensions` | `htmx:configRequest`, `htmx:afterSwap`, `hx-on`, `hx-indicator`, `hx-disabled-elt`, the json-enc extension |

41 exercises. Some are fixed in the page, some in `handlers.js`, a few in
both; the comment at the top of each file says which.

## Writing handlers

`handlers.js` default-exports a route table, or a function returning one
(for routes that keep state; tests get a fresh copy):

```js
import { html } from '../../../lib/html.js';

export default {
  'GET /contacts/:id': ({ params, query, form, headers }) => html`<p>${params.id}</p>`,
  'POST /login': () => ({ status: 200, headers: { 'HX-Redirect': '/' }, body: '' }),
};
```

`form` is the parsed urlencoded or JSON body (repeated keys become arrays),
`headers` are lower-cased. Return a string (sent as `text/html`) or
`{ status, headers, body }`. `html` escapes interpolated values; arrays of
`html` results are joined. Files in the exercise directory are served too:
`/` is `index.html`, `/about` is `about.html`, and `/htmx.js`,
`/ext/json-enc.js`, `/style.css` come from the course.

## Layout

```
exercises/      the files you edit, one directory per exercise
solutions/      one reference solution per exercise
.templates/     pristine copies, used by `reset`
tests/          the specs (vitest + jsdom), one per exercise; discovery is driven by these
tests/helpers.js  openPage / serve / until: the harness that runs htmx in jsdom
lib/server.js   the zero-dependency node:http server used by tests and `serve`
lib/html.js     the escaping html`` template tag
runner/         the CLI's pieces; htmxlings.js is the entry point
scripts/        verify-all.sh: every solution passes, every exercise
                untouched fails
```

jsdom lacks a few things htmx 2 touches: `XPathExpression.evaluate`
without a result type, `scrollIntoView`, `scrollTo`, and layout (so every
`revealed` element counts as visible). `tests/helpers.js` shims the first
three; `intersect` triggers are not covered for want of `IntersectionObserver`.

## Adding an exercise

Create `exercises/<chapter>/<name>/` with an `index.html` (a comment block
at the top: title, concept, task, `npm run serve <name>`) and whatever
`handlers.js` it needs; its tests must fail as shipped. Copy it to `.templates/`, write the fixed version
under `solutions/`, and add `tests/<chapter>/<name>.test.js` with a
`/* HINT ... */` block at the bottom. Then run `scripts/verify-all.sh`.
Ordering is by chapter, then natural sort of the exercise name.

## Other ways to learn htmx

- [htmx.org docs](https://htmx.org/docs/) and the [attribute reference](https://htmx.org/reference/)
- [htmx examples](https://htmx.org/examples/): most of `06_patterns` comes from here
- [Hypermedia Systems](https://hypermedia.systems/), the book by the htmx authors, free online
- [htmx essays](https://htmx.org/essays/), on why hypermedia and when not to use it
