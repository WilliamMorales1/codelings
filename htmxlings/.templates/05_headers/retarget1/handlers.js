// retarget1 - server routes. TASK: route errors to #errors.
import { html } from '../../../lib/html.js';

export default {
  'POST /comments': ({ form }) => {
    const text = (form.text ?? '').trim();
    if (!text) {
      return { body: html`<p>A comment cannot be empty.</p>` };
    }
    return html`<li>${text}</li>`;
  },
};
