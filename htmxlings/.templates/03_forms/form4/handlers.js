// form4 - server routes. TASK: validate before signing anyone up.
import { html } from '../../../lib/html.js';

const signupForm = (values = {}, errors = {}) => html`
<form hx-post="/signup" hx-target="this" hx-swap="outerHTML">
  <label>Username <input name="username" value="${values.username ?? ''}"></label>
  ${errors.username && html`<span class="error">${errors.username}</span>`}
  <label>Email <input name="email" value="${values.email ?? ''}"></label>
  ${errors.email && html`<span class="error">${errors.email}</span>`}
  <button>Sign up</button>
</form>`;

export default {
  'POST /signup': ({ form }) => {
    // TODO: collect errors.username / errors.email and re-render the form when there are any.
    return html`<p id="welcome">Welcome, ${form.username}!</p>`;
  },
};
