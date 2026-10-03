// emitter1 — A typed event emitter
//
// Stringly-typed events (`emit('login', anything)`) are a classic source of
// bugs: a typo in the name or the wrong payload fails silently. A type
// parameter mapping event names to argument tuples fixes both:
//
//   type Events = { login: [user: string]; logout: [] };
//   const bus = new Emitter<Events>();
//   bus.on('login', (user) => ...)   // user: string
//   bus.emit('login', 'ada');        // checked
//
// (Node's own EventEmitter accepts such a map too: `new EventEmitter<Events>()`.)
//
// Task: make Emitter generic over an event map and type on/off/emit with
// `K extends keyof Events` and `Events[K]`. The runtime part also needs
// finishing: `off` should remove a listener, and `on` should return a
// function that unsubscribes.

type ListenerMap<Events extends Record<string, unknown[]>> = {
  [K in keyof Events]?: Set<(...args: Events[K]) => void>;
};

export class Emitter<Events extends Record<string, unknown[]>> {
  #listeners: ListenerMap<Events> = {};

  on<K extends keyof Events>(event: K, listener: (...args: Events[K]) => void): () => void {
    const set = (this.#listeners[event] ??= new Set());
    set.add(listener);
    return () => this.off(event, listener);
  }

  off<K extends keyof Events>(event: K, listener: (...args: Events[K]) => void): void {
    this.#listeners[event]?.delete(listener);
  }

  emit<K extends keyof Events>(event: K, ...args: Events[K]): void {
    for (const l of this.#listeners[event] ?? []) l(...args);
  }
}
