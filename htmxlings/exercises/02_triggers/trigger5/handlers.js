// trigger5 - server routes (nothing to change here).
import { html } from '../../../lib/html.js';

export default {
  'GET /help': () => html`<ul><li><kbd>c</kbd> compose</li><li><kbd>/</kbd> search</li></ul>`,
};
