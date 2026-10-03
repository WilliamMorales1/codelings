// trigger3 - server routes (nothing to change here).
import { html } from '../../../lib/html.js';

export default function routes() {
  let checks = 0;
  return {
    'GET /status': () => html`<span class="ok">up</span> (check #<span id="n">${++checks}</span>)`,
  };
}
