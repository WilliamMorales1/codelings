// clickedit - server routes. TASK: implement PUT /contact/1.
import { html } from '../../../lib/html.js';

export default function routes() {
  const contact = { firstName: 'Joe', lastName: 'Blow', email: 'joe@blow.com' };

  const view = () => html`<div id="contact" hx-target="this" hx-swap="outerHTML">
  <p><b>First name</b>: <span class="first">${contact.firstName}</span></p>
  <p><b>Last name</b>: <span class="last">${contact.lastName}</span></p>
  <p><b>Email</b>: <span class="email">${contact.email}</span></p>
  <button hx-get="/contact/1/edit">Edit</button>
</div>`;

  const form = () => html`<form id="contact" hx-put="/contact/1" hx-target="this" hx-swap="outerHTML">
  <label>First name <input name="firstName" value="${contact.firstName}"></label>
  <label>Last name <input name="lastName" value="${contact.lastName}"></label>
  <label>Email <input name="email" value="${contact.email}"></label>
  <button>Save</button>
  <button type="button" hx-get="/contact/1">Cancel</button>
</form>`;

  return {
    'GET /contact/1': () => view(),
    'GET /contact/1/edit': () => form(),
    'PUT /contact/1': ({ form }) => ({ status: 501, body: 'not implemented' }),
  };
}
