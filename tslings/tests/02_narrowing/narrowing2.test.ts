import { expect, it } from 'vitest';
import { errorMessage, move } from '@ex/02_narrowing/narrowing2.ts';

it('moves fish and birds', () => {
  expect(move({ swim: () => 'splash' })).toBe('splash');
  expect(move({ fly: () => 'flap' })).toBe('flap');
});

it('reads messages from anything that was thrown', () => {
  expect(errorMessage(new TypeError('bad type'))).toBe('bad type');
  expect(errorMessage('plain string')).toBe('plain string');
  expect(errorMessage(404)).toBe('404');
});

/* HINT
  if ('swim' in animal) return animal.swim();
  return animal.fly();          // only Bird is left here
and
  if (e instanceof Error) return e.message;
  return String(e);
*/
