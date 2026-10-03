import { expect, expectTypeOf, it } from 'vitest';
import { badge, labels, type Status } from '@ex/05_utility_types/record1.ts';

it('labels every status', () => {
  expect(badge('draft')).toBe('[Draft]');
  expect(badge('archived')).toBe('[Archived]');
});

it('is a Record over Status', () => {
  expectTypeOf(labels).toEqualTypeOf<Record<Status, string>>();
});

/* HINT
`export const labels: Record<Status, string> = { ... }` — the compiler now
says: Property 'archived' is missing. Add it.
*/
