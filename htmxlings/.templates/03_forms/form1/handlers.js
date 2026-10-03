// form1 - server routes (nothing to change here).
import { html } from '../../../lib/html.js';

export default {
  'POST /subscribe': ({ form }) => html`<p class="thanks">Thanks, ${form.email}!</p>`,
};
