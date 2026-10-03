import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('the page centres its child both ways', async () => {
  const page = await load('02_layout/center1');
  const p = page.style('#page');
  expect(['grid', 'flex'], `#page display is ${p.get('display')}`).toContain(p.get('display'));
  expect(p.get('min-height')).toBe('100vh');
  const both = p.get('place-items') === 'center' || (p.get('align-items') === 'center' && p.get('justify-content') === 'center');
  expect(both, 'centred on both axes (place-items-center, or items-center + justify-center)').toBe(true);
});

test('the avatar centres its initials', async () => {
  const page = await load('02_layout/center1');
  const a = page.style('#avatar');
  expect(['flex', 'inline-flex', 'grid', 'inline-grid'], `#avatar display is ${a.get('display')}`).toContain(a.get('display'));
  const both = a.get('place-items') === 'center' || (a.get('align-items') === 'center' && a.get('justify-content') === 'center');
  expect(both, 'centred on both axes').toBe(true);
});

/* HINT
`text-center` only centres inline content horizontally. For the page:
`grid place-items-center` (keep `min-h-screen`). For the avatar:
`inline-flex items-center justify-center`.
*/
