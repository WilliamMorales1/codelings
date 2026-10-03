// inner1 - server routes (nothing to change here).
import { html } from '../../../lib/html.js';

export default {
  'POST /follow': () => html`<button class="unfollow" hx-post="/unfollow" hx-swap="outerHTML">Unfollow</button>`,
  'POST /unfollow': () => html`<button class="follow" hx-post="/follow" hx-swap="outerHTML">Follow</button>`,
};
