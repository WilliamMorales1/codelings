// jsonenc1 - a JSON-only API (nothing to change here).
import { html } from '../../../lib/html.js';

export default {
  'POST /api/pets': ({ form, headers }) => {
    if (!(headers['content-type'] ?? '').startsWith('application/json')) {
      return { status: 415, body: 'send JSON' };
    }
    return html`<p id="saved">Saved ${form.name} (${[].concat(form.tags).join(', ')})</p>`;
  },
};
