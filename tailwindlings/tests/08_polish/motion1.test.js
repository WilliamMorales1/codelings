import { expect, test } from 'vitest';
import { load } from '../helpers.js';

const reduce = { reducedMotion: true };

test('the arrow bounces by default', async () => {
  const page = await load('08_polish/motion1');
  expect(page.get('#arrow', 'animation')).toBe(page.theme('--animate-bounce'));
});

test('the arrow is still with reduced motion', async () => {
  const page = await load('08_polish/motion1');
  const a = page.get('#arrow', 'animation', reduce);
  expect(a === undefined || a === 'none', `#arrow animation with reduced motion: ${a}`).toBe(true);
});

test('the card lifts on hover by default', async () => {
  const page = await load('08_polish/motion1');
  expect(page.num('#card', 'transition-duration')).toBeGreaterThan(0);
  expect(page.num('#card', '--tw-translate-y', { hover: '#card' })).toBe(-4);
});

test('with reduced motion the card neither transitions nor moves', async () => {
  const page = await load('08_polish/motion1');
  expect(page.get('#card', 'transition-property', reduce), 'transition-property').toBe('none');
  const y = page.num('#card', '--tw-translate-y', { ...reduce, hover: '#card' });
  expect(y === 0 || Number.isNaN(y), `hovered translate-y is ${y}`).toBe(true);
  expect(page.get('#card', 'border-top-color', { ...reduce, hover: '#card' }), 'colour change kept').toBe(page.theme('--color-sky-500'));
});

/* HINT
Arrow: `motion-safe:animate-bounce`. Card: add `motion-reduce:transition-none`
and `motion-reduce:hover:translate-y-0` (variants stack).
*/
