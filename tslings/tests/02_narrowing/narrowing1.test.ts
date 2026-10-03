import { expect, it } from 'vitest';
import { toLabel } from '@ex/02_narrowing/narrowing1.ts';

it('labels strings', () => expect(toLabel('hi')).toBe('HI'));
it('labels numbers', () => expect(toLabel(3.14159)).toBe('3.14'));
it('labels arrays', () => expect(toLabel(['a', 'b'])).toBe('a, b'));
it('labels null', () => expect(toLabel(null)).toBe('(none)'));

/* HINT
Handle null first (`if (value === null) return '(none)';`), then
`typeof value === 'string'`, then `typeof value === 'number'`. Whatever is
left can only be string[], so TypeScript lets you call `.join` on it without
another check.
*/
