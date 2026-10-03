// form5 - server routes (nothing to change here).
import { html } from '../../../lib/html.js';

export default {
  'POST /coupon': ({ form }) =>
    form.code === 'HTMX10'
      ? html`<p class="ok">10% off!</p>`
      : { status: 422, body: html`<p class="error">Unknown coupon ${form.code}</p>` },
};
