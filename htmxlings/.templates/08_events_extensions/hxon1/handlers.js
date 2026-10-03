// hxon1 - server routes (nothing to change here).
import { html } from '../../../lib/html.js';

export default {
  'POST /notes': ({ form }) =>
    form.text.length > 20 ? { status: 400, body: 'too long' } : html`<li>${form.text}</li>`,
};
