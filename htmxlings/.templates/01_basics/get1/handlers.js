// get1 - server routes (nothing to change here).
import { html } from '../../../lib/html.js';

export default {
  'GET /quote': () => html`<blockquote>Simplicity is prerequisite for reliability.</blockquote>`,
};
