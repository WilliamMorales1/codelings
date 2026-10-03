// pushurl1 - server routes (nothing to change here).
import { html } from '../../../lib/html.js';
import fs from 'node:fs';

const titles = ['Hypermedia Systems', 'The Web Browser as a Platform', 'REST in Practice'];

const results = (q) =>
  html`<ul>${titles.filter((t) => t.toLowerCase().includes(q.toLowerCase())).map((t) => html`<li>${t}</li>`)}</ul>`;

export default {
  'GET /search': ({ query, headers }) => {
    const frag = results(query.q ?? '');
    if (headers['hx-request'] === 'true' && !headers['hx-history-restore-request']) return frag;
    // Full page: the static index.html with the results filled in.
    const index = fs.readFileSync(new URL('./index.html', import.meta.url), 'utf8');
    return index.replace('<div id="results"></div>', `<div id="results">${frag}</div>`);
  },
};
