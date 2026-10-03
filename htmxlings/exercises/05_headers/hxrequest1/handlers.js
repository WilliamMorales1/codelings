// hxrequest1 - server routes. TASK: full page for browsers, fragment for htmx.
import { html } from '../../../lib/html.js';

const messages = ['Lunch?', 'Invoice #42', 'htmx 2.0.11 released'];

const layout = (content) => html`<!doctype html>
<html>
<head><title>Mail</title><link rel="stylesheet" href="/style.css"><script src="/htmx.js"></script></head>
<body>
  <h1>Mail</h1>
  <nav><button hx-get="/inbox" hx-target="#main">Inbox</button></nav>
  <main id="main">${content}</main>
</body>
</html>`;

const inbox = () => html`<ul class="inbox">${messages.map((m) => html`<li>${m}</li>`)}</ul>`;

export default {
  'GET /inbox': ({ headers }) => inbox(),
};
