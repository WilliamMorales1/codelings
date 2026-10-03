// redirect1 - server routes. TASK: redirect the htmx way.
import { html } from '../../../lib/html.js';

export default {
  'POST /login': ({ form, headers }) => {
    if (form.user !== 'admin' || form.password !== 'hunter2') {
      return html`<p class="error">Wrong user or password</p>`;
    }
    return { status: 302, headers: { location: '/dashboard' } };
  },
  'GET /dashboard': () => html`<!doctype html><html><head><title>Dashboard</title></head>
    <body><h1 id="dashboard">Dashboard</h1></body></html>`,
};
