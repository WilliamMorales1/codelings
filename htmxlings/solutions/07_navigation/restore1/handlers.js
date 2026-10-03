// restore1 - deep links and history restores
//
// Once URLs are pushed, every one of them can be reloaded, bookmarked,
// or restored by htmx itself: when Back hits a page that is not in its
// history cache, htmx re-fetches it with the headers
//   HX-Request: true  and  HX-History-Restore-Request: true
// and replaces the whole <body> with the response.
// So one URL must answer two ways:
//   - a fragment for ordinary htmx requests (the tab buttons),
//   - the full page for everything else, history restores included.
// And because the same URL now has two representations, tell caches
// with the response header  Vary: HX-Request.
//
// This page is rendered entirely here; there is no index.html.
//
// TASK: GET /tab/:n always returns the fragment. Fix it as described.
//
// Try it in a browser: npm run serve restore1
import { html } from '../../../lib/html.js';

const tabs = { 1: 'Overview of the project.', 2: 'Detailed specs.', 3: 'Frequently asked questions.' };

const tab = (n) => html`<div class="tab-content"><h2>Tab ${n}</h2><p>${tabs[n]}</p></div>`;

const layout = (n) => html`<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8"><title>restore1</title>
  <link rel="stylesheet" href="/style.css"><script src="/htmx.js"></script>
</head>
<body>
  <h1>Project</h1>
  <nav hx-target="#tab" hx-push-url="true">
    ${Object.keys(tabs).map((k) => html`<button hx-get="/tab/${k}">Tab ${k}</button> `)}
  </nav>
  <section id="tab">${tab(n)}</section>
</body>
</html>`;

export default {
  'GET /': () => layout(1),
  'GET /tab/:n': ({ params, headers }) => {
    if (!(params.n in tabs)) return { status: 404, body: 'no such tab' };
    const fragment = headers['hx-request'] === 'true' && headers['hx-history-restore-request'] !== 'true';
    return { headers: { Vary: 'HX-Request' }, body: fragment ? tab(params.n) : layout(params.n) };
  },
};
