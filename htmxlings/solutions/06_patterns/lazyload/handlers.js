// lazyload - the Lazy Loading pattern
//
// A slow part of a page should not hold up the rest of it. Send the page
// straight away with a placeholder that fetches the slow part itself:
//   <div hx-get="/report" hx-trigger="load" hx-swap="outerHTML">Loading...</div>
// (https://htmx.org/examples/lazy-load/)
//
// This exercise is all server: the page itself is rendered by GET / below.
//
// TASK: GET / waits for the slow report before sending anything. Make it
// respond immediately with a placeholder (as above), and add a
// GET /report route that returns the report once it is ready. The
// report must replace the placeholder, not end up inside it.
//
// Try it in a browser: npm run serve lazyload
import { html } from '../../../lib/html.js';

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function slowReport() {
  await sleep(600); // pretend this is a heavy query
  return html`<table id="report">
  <tr><th>Quarter</th><th>Sales</th></tr>
  <tr><td>Q1</td><td>120</td></tr>
  <tr><td>Q2</td><td>180</td></tr>
</table>`;
}

const layout = (content) => html`<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8"><title>lazyload</title>
  <link rel="stylesheet" href="/style.css"><script src="/htmx.js"></script>
</head>
<body>
  <h1>Sales dashboard</h1>
  <p id="intro">Numbers for this year.</p>
  ${content}
</body>
</html>`;

export default {
  'GET /': () =>
    layout(html`<div class="placeholder" hx-get="/report" hx-trigger="load" hx-swap="outerHTML">Loading report...</div>`),
  'GET /report': () => slowReport(),
};
