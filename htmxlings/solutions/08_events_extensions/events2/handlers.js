// events2 - server routes (nothing to change here).
import { html } from '../../../lib/html.js';

export default function routes() {
  const inbox = [];
  let n = 0;
  return {
    'GET /messages': () => {
      inbox.push(`Message ${++n}`, `Message ${++n}`);
      return html`${inbox.map((m) => html`<li>${m}</li>`)}`;
    },
  };
}
