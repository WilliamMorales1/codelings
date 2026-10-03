// progress - server routes. TASK: stop the polling when the job is done.
import { html } from '../../../lib/html.js';

export default function routes() {
  let percent = 0;
  const bar = () => html`<div class="progress"><div style="width: ${percent}%"></div></div>
    <span id="pct">${percent}%</span>`;

  return {
    'POST /jobs': () => {
      percent = 0;
      return html`<div hx-get="/jobs/progress" hx-trigger="every 150ms">${bar()}</div>`;
    },
    'GET /jobs/progress': () => {
      percent = Math.min(100, percent + 25);
      if (percent === 100) return { status: 286, body: html`<p id="done">Export finished!</p>` };
      return bar();
    },
  };
}
