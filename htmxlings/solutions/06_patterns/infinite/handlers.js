// infinite - server routes. TASK: fix the attributes of the "load more" row.
import { html } from '../../../lib/html.js';

const PER_PAGE = 10;
const TOTAL = 50;

export default {
  'GET /agents': ({ query }) => {
    const page = Number(query.page ?? 1);
    const rows = [];
    for (let i = (page - 1) * PER_PAGE + 1; i <= Math.min(page * PER_PAGE, TOTAL); i++) {
      const last = i === page * PER_PAGE && i < TOTAL;
      rows.push(
        last
          ? html`<tr hx-get="/agents?page=${page + 1}" hx-trigger="revealed" hx-swap="afterend"><td>${i}</td><td>Agent ${i}</td></tr>`
          : html`<tr><td>${i}</td><td>Agent ${i}</td></tr>`,
      );
    }
    return html`${rows}`;
  },
};
