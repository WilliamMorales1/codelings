// hxtrigger1 - server routes. TASK: announce new contacts with HX-Trigger.
import { html } from '../../../lib/html.js';

export default function routes() {
  const contacts = ['Ada', 'Grace'];
  return {
    'GET /contacts/count': () => String(contacts.length),
    'POST /contacts': ({ form }) => {
      contacts.push(form.name);
      return { body: html`<li>${form.name}</li>` };
    },
  };
}
