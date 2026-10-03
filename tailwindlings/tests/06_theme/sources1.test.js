import { expect, test } from 'vitest';
import { exPath, load } from '../helpers.js';

// Runs app.js's class logic against the page, as the browser would.
async function applyScript(page) {
  const { badgeClasses } = await import(`${exPath('06_theme/sources1')}/app.js?t=${Date.now()}`).catch(() => ({}));
  const hue = { ok: 'green', warn: 'amber', down: 'red' };
  const classes = badgeClasses ?? ((s) => ['rounded-full', 'px-2', `bg-${hue[s]}-100`, `text-${hue[s]}-800`]);
  for (const el of page.$$('[data-status]')) el.className = classes(el.dataset.status).join(' ');
  page.refresh();
}

test.each([
  ['#api', 'green'],
  ['#db', 'amber'],
  ['#cdn', 'red'],
])('%s gets its %s badge colours', async (id, hue) => {
  const page = await load('06_theme/sources1');
  await applyScript(page);
  expect(page.get(id, 'background-color'), `${id} bg-${hue}-100`).toBe(page.theme(`--color-${hue}-100`));
  expect(page.get(id, 'color'), `${id} text-${hue}-800`).toBe(page.theme(`--color-${hue}-800`));
});

/* HINT
One line after the import covers all six classes:
  @source inline("{bg,text}-{green,amber,red}-{100,800}");
The better long-term fix is a lookup table of complete class names in
app.js ({ ok: 'bg-green-100 text-green-800', ... }), which the scanner can
read.
*/
