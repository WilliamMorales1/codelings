import { expect, it } from 'vitest';
import { MemoryStore, type KeyValueStore } from '@ex/07_classes_modules/implements1.ts';

it('stores values', () => {
  const s: KeyValueStore = new MemoryStore();
  s.set('a', '1');
  s.set('b', '2');
  expect(s.get('a')).toBe('1');
  expect(s.size).toBe(2);
  expect(s.delete('a')).toBe(true);
  expect(s.delete('a')).toBe(false);
  expect(s.get('a')).toBeUndefined();
  expect(s.size).toBe(1);
});

/* HINT
`set` must take `value: string` (store it as is). Add
  delete(key: string): boolean { return this.#data.delete(key); }
*/
