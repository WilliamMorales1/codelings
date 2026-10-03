// oob1 - server routes. TASK: update #count out of band.
import { html } from '../../../lib/html.js';

export default function routes() {
  const todos = [];
  return {
    'POST /todos': ({ form }) => {
      todos.push(form.title);
      return html`<li>${form.title}</li>`;
    },
  };
}
