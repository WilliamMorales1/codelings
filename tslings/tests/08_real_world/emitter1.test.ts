import { expect, expectTypeOf, it, vi } from 'vitest';
import { Emitter } from '@ex/08_real_world/emitter1.ts';

type Events = {
  login: [user: string];
  logout: [];
  error: [code: number, message: string];
};

it('delivers events', () => {
  const bus = new Emitter<Events>();
  const seen: string[] = [];
  bus.on('login', (user) => {
    expectTypeOf(user).toEqualTypeOf<string>();
    seen.push(user);
  });
  bus.on('error', (code, message) => seen.push(`${code} ${message}`));
  bus.emit('login', 'ada');
  bus.emit('error', 500, 'oops');
  bus.emit('logout');
  expect(seen).toEqual(['ada', '500 oops']);
});

it('unsubscribes', () => {
  const bus = new Emitter<Events>();
  const a = vi.fn();
  const b = vi.fn();
  const stopA = bus.on('logout', a);
  bus.on('logout', b);
  stopA();
  bus.off('logout', b);
  bus.emit('logout');
  expect(a).not.toHaveBeenCalled();
  expect(b).not.toHaveBeenCalled();
});

it('checks names and payloads', () => {
  const bus = new Emitter<Events>();
  // @ts-expect-error no such event
  bus.emit('logon', 'ada');
  // @ts-expect-error login takes a string
  bus.emit('login', 42);
  // @ts-expect-error error needs two arguments
  bus.emit('error', 500);
});

/* HINT
  class Emitter<Events extends Record<string, unknown[]>> {
    on<K extends keyof Events>(event: K, listener: (...args: Events[K]) => void): () => void
    emit<K extends keyof Events>(event: K, ...args: Events[K]): void
Store listeners in a mapped type, so each event keeps its own listener type:
  #listeners: { [K in keyof Events]?: Set<(...args: Events[K]) => void> } = {};
and `this.#listeners[event] ??= new Set()` creates a set on first use.
on() returns `() => this.off(event, listener)`; off() deletes from the set.
*/
