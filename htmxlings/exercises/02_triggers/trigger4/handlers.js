// trigger4 - server routes (nothing to change here).
import { html } from '../../../lib/html.js';

export default function routes() {
  let n = 0;
  return {
    'GET /prices': () => html`<p>BTC ${40000 + ++n}</p>`,
    'POST /coupon': () => html`<p>Your code: HTMX-${Math.random().toString(36).slice(2, 8)}</p>`,
  };
}
