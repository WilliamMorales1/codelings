// trigger2 - server routes (nothing to change here).
import { html } from '../../../lib/html.js';

export default {
  'GET /stats': () => html`<dl><dt>Visitors</dt><dd id="visitors">1,024</dd></dl>`,
};
