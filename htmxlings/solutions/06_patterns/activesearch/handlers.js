// activesearch - server routes. TASK: filter by the query in form.q.
import { html } from '../../../lib/html.js';

const contacts = [
  { name: 'Ada Lovelace', email: 'ada@analytical.engine' },
  { name: 'Grace Hopper', email: 'grace@navy.mil' },
  { name: 'Katherine Johnson', email: 'kj@nasa.gov' },
  { name: 'Margaret Hamilton', email: 'margaret@mit.edu' },
  { name: 'Alan Turing', email: 'alan@bletchley.uk' },
];

const row = (c) => html`<tr><td>${c.name}</td><td>${c.email}</td></tr>`;

export default {
  'POST /search': ({ form }) => {
    const q = (form.q ?? '').toLowerCase();
    const found = contacts.filter((c) => (c.name + ' ' + c.email).toLowerCase().includes(q));
    return html`${found.map(row)}`;
  },
};
