// swap1 - server routes (nothing to change here).
import { html } from '../../../lib/html.js';

export default function routes() {
  let n = 0;
  return {
    'POST /event': () => html`<li>event ${++n}</li>`,
    'POST /pin': () => html`<li class="pinned">pinned note</li>`,
  };
}
