// node4.js -- reference solution.

import { EventEmitter, once } from 'node:events';

export class Store extends EventEmitter {
  #data = new Map();

  constructor(initial = {}) {
    super();
    for (const [k, v] of Object.entries(initial)) this.#data.set(k, v);
  }

  get(key) {
    return this.#data.get(key);
  }

  set(key, value) {
    const previous = this.#data.get(key);
    if (Object.is(previous, value)) return this;
    this.#data.set(key, value);
    this.emit('change', key, value, previous);
    return this;
  }

  nextChange() {
    return once(this, 'change');
  }
}
