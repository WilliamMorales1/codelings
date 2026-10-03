// intro1 - the server side of the exercise.
//
// Each key is "METHOD /path"; the function gets { query, form, headers, params }
// and returns an HTML string, or { status, headers, body } for anything fancier.
// Static pages (index.html, about.html, ...) are served automatically.
import { html } from '../../../lib/html.js';

export default {
  'GET /hello': () => html`<p>Hello from the client!</p>`,
};
