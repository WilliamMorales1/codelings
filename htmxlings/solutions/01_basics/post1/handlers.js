// post1 - server routes. TASK: return HTML, not JSON.
import { html } from '../../../lib/html.js';

export default function routes() {
  let likes = 0;
  return {
    'POST /like': () => {
      likes++;
      return html`<span id="likes">${likes} likes</span>`;
    },
  };
}
