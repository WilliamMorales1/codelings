// narrowing2 — `in` and `instanceof`
//
// typeof can't tell two object types apart. Two more narrowing tools:
//
//   'swim' in animal      narrows to the union members that have `swim`
//   err instanceof Error  narrows to Error (works on classes only)
//
// `catch (e)` gives you `unknown` under strict mode: anything can be thrown,
// including strings. You must narrow before touching `.message`.
//
// Task: fix `move` and `errorMessage`. For a thrown non-Error, use String(e).

export interface Fish {
  swim(): string;
}
export interface Bird {
  fly(): string;
}

export function move(animal: Fish | Bird): string {
  if ('swim' in animal) return animal.swim();
  return animal.fly();
}

export function errorMessage(e: unknown): string {
  if (e instanceof Error) return e.message;
  return String(e);
}
