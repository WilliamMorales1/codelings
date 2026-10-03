import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('hovered, the card is scaled to 105% with a sky border', async () => {
  const page = await load('08_polish/transitions1');
  const h = page.style('#card', { hover: '#card' });
  expect(h.get('scale')).toBe('105% 105%');
  expect(h.get('border-top-color')).toBe(page.theme('--color-sky-500'));
});

test('both the scale and the border colour transition', async () => {
  const page = await load('08_polish/transitions1');
  const props = (page.get('#card', 'transition-property') ?? '').split(/\s*,\s*/);
  expect(props, 'transition-property includes scale').toContain('scale');
  expect(props, 'transition-property includes border-color').toContain('border-color');
});

test('over 200ms, easing out', async () => {
  const page = await load('08_polish/transitions1');
  expect(page.num('#card', 'transition-duration'), 'duration (ms)').toBe(200);
  expect(page.get('#card', 'transition-timing-function')).toBe(page.theme('--ease-out'));
});

/* HINT
`transition-colors` leaves `scale` out, so the grow snaps. Use `transition`
(colours + transforms + more), then `duration-200 ease-out`.
*/
