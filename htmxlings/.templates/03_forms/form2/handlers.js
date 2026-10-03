// form2 - server routes (nothing to change here).
import { html } from '../../../lib/html.js';

const books = [
  { title: 'Hypermedia Systems', year: 2023 },
  { title: 'RESTful Web APIs', year: 2013 },
  { title: 'The Pragmatic Programmer', year: 1999 },
  { title: 'HTTP: The Definitive Guide', year: 2002 },
];

export default {
  'GET /books': ({ query }) => {
    const q = (query.q ?? '').toLowerCase();
    const list = books
      .filter((b) => b.title.toLowerCase().includes(q))
      .toSorted((a, b) => (query.sort === 'year' ? a.year - b.year : a.title.localeCompare(b.title)));
    return html`${list.map((b) => html`<li>${b.title} (${b.year})</li>`)}`;
  },
};
