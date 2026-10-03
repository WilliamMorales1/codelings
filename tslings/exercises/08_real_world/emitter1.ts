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
//

type Listener = (...args: any[]) => void;

export class Emitter {
  #listeners = new Map<string, Set<Listener>>();

  on(event: string, listener: Listener): () => void {
    let set = this.#listeners.get(event);
    if (!set) this.#listeners.set(event, (set = new Set()));
    set.add(listener);
    return () => {};
  }

  off(event: string, listener: Listener): void {}

  emit(event: string, ...args: any[]): void {
    for (const l of this.#listeners.get(event) ?? []) l(...args);
  }
}
