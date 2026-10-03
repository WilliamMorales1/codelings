// node4.js
//
// EventEmitter
//
// Many Node APIs (streams, servers, child processes) are EventEmitters: they
// call `emit(name, ...args)` and listeners registered with `on(name, fn)`
// receive those args. You can extend EventEmitter for your own classes, and
// `once(emitter, name)` from `node:events` turns the next event into a
// Promise that resolves to the array of its arguments.
//
// Task: fix Store.
//   - `set(key, value)` emits 'change' with three arguments:
//     (key, value, previousValue) -- and emits nothing when the value is
//     unchanged. It returns the store, so calls can be chained.
//   - `nextChange()` returns a Promise of the next change's [key, value, previous],
//     without leaving a listener behind.

import { EventEmitter, once } from 'node:events';

export class Store extends EventEmitter {
  #data = new Map();

  constructor(initial = {}) {
    for (const [k, v] of Object.entries(initial)) this.#data.set(k, v);
  }

  get(key) {
    return this.#data.get(key);
  }

  set(key, value) {
    this.#data.set(key, value);
    this.emit('change', { key, value });
  }

  nextChange() {
    this.on('change', (...args) => args);
  }
}
