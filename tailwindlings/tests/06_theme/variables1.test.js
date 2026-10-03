import { expect, test } from 'vitest';
import { color, load } from '../helpers.js';

for (const [id, want] of [['#bug', '#dc2626'], ['#docs', '#2563eb']]) {
  test(`${id} text and border follow its --accent`, async () => {
    const page = await load('06_theme/variables1');
    expect(color(page.get(id, 'color')), `${id} text`).toBe(want);
    expect(color(page.get(id, 'border-top-color')), `${id} border`).toBe(want);
    expect(page.num(id, 'border-top-width')).toBe(1);
  });
}

/* HINT
Swap the square brackets for parentheses: `border-(--accent)` and
`text-(--accent)`. Tailwind wraps them in var() for you.
*/
