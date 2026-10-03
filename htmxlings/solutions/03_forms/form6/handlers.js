// form6 - server routes (nothing to change here).
import { html } from '../../../lib/html.js';

export default {
  'DELETE /account': () => html`<p id="gone">Your account has been deleted.</p>`,
};
