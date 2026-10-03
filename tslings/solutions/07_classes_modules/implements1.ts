// implements1 — Classes implementing interfaces
//
// `class X implements I` asks the compiler to check that X has everything I
// describes, with compatible types. It adds nothing at runtime: it's a
// check, reported at the class instead of at the first place you pass an X
// where an I is expected.
//
// Task: make MemoryStore a correct KeyValueStore. Read the errors: one
// method is missing and one has the wrong signature.

export interface KeyValueStore {
  get(key: string): string | undefined;
  set(key: string, value: string): void;
  delete(key: string): boolean;
  readonly size: number;
}

export class MemoryStore implements KeyValueStore {
  #data = new Map<string, string>();

  get(key: string): string | undefined {
    return this.#data.get(key);
  }

  set(key: string, value: string): void {
    this.#data.set(key, value);
  }

  delete(key: string): boolean {
    return this.#data.delete(key);
  }

  get size(): number {
    return this.#data.size;
  }
}
