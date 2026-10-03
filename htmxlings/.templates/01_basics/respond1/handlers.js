// respond1 - server routes. TASK: GET /contacts should return a fragment.
import { html } from '../../../lib/html.js';

const contacts = ['Ada Lovelace', 'Grace Hopper', 'Katherine Johnson'];

const layout = (title, content) => html`<!doctype html>
<html>
<head><title>${title}</title><script src="/htmx.js"></script></head>
<body>
  <nav><a href="/">Home</a></nav>
  <h1>${title}</h1>
  ${content}
</body>
</html>`;

const items = () => contacts.map((c) => html`<li>${c}</li>`);

export default {
  'GET /contacts': () => layout('Contacts', html`<ul>${items()}</ul>`),
};
