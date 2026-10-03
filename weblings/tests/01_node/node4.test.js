import { EventEmitter } from 'node:events';
import { expect, test, vi } from 'vitest';
import { Store } from '@ex/01_node/node4.js';

test('a Store is an EventEmitter with initial data', () => {
  const s = new Store({ theme: 'dark' });
  expect(s).toBeInstanceOf(EventEmitter);
  expect(s.get('theme')).toBe('dark');
});

test("'change' gets key, new value and previous value", () => {
  const s = new Store({ count: 1 });
  const seen = vi.fn();
  s.on('change', seen);
  s.set('count', 2);
  expect(seen).toHaveBeenCalledWith('count', 2, 1);
});

test('setting the same value emits nothing', () => {
  const s = new Store({ count: 1 });
  const seen = vi.fn();
  s.on('change', seen);
  s.set('count', 1);
  expect(seen).not.toHaveBeenCalled();
});

test('set is chainable', () => {
  const s = new Store();
  expect(s.set('a', 1).set('b', 2)).toBe(s);
  expect(s.get('b')).toBe(2);
});

test('nextChange resolves once and cleans up after itself', async () => {
  const s = new Store();
  const next = s.nextChange();
  setTimeout(() => s.set('user', 'ada'), 5);
  await expect(next).resolves.toEqual(['user', 'ada', undefined]);
  expect(s.listenerCount('change')).toBe(0);
});

/* HINT
A subclass constructor must call `super()` before touching `this`.
Emit separate arguments: `this.emit('change', key, value, previous)`, and read
`previous` before you overwrite it. `return this` at the end of set.
`nextChange` is one line with `once(this, 'change')` from node:events.
*/
