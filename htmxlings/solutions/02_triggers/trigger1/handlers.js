// trigger1 - server routes (nothing to change here).
import { html } from '../../../lib/html.js';

const words = ['htmx', 'html', 'hypermedia', 'hyperscript', 'http', 'rest'];

export default {
  'GET /search': ({ query }) =>
    html`${words.filter((w) => w.startsWith(query.q ?? '')).map((w) => html`<li>${w}</li>`)}`,
};
