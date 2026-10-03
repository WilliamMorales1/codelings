// validate1 — A tiny runtime validator with type inference
//
// Libraries like zod and valibot let you write a schema once and get both a
// runtime check and a static type from it. The trick is small enough to
// build yourself: a schema is an object with a `parse(unknown): T` method,
// and `Infer<S>` pulls T back out with `infer`.
//
//   const User = object({ name: string(), tags: array(string()) });
//   type User = Infer<typeof User>;   // { name: string; tags: string[] }
//
// string(), number(), boolean() and array() are done. Task:
//   - Infer<S>      the type a schema produces
//   - object(shape) a schema for an object whose properties follow `shape`;
//     parse must check every property and report the path of the first bad
//     one in the error, e.g. "tags.1: expected string".

export interface Schema<T> {
  parse(input: unknown, path?: string): T;
}

function fail(path: string, expected: string): never {
  throw new Error(`${path || '(root)'}: expected ${expected}`);
}

const primitive = <T>(name: string, check: (x: unknown) => x is T): (() => Schema<T>) =>
  () => ({ parse: (input, path = '') => (check(input) ? input : fail(path, name)) });

export const string = primitive('string', (x): x is string => typeof x === 'string');
export const number = primitive('number', (x): x is number => typeof x === 'number' && !Number.isNaN(x));
export const boolean = primitive('boolean', (x): x is boolean => typeof x === 'boolean');

export function array<T>(item: Schema<T>): Schema<T[]> {
  return {
    parse(input, path = '') {
      if (!Array.isArray(input)) return fail(path, 'array');
      return input.map((x, i) => item.parse(x, path ? `${path}.${i}` : String(i)));
    },
  };
}

export type Infer<S> = S extends Schema<infer T> ? T : never;

export function object<Shape extends Record<string, Schema<unknown>>>(
  shape: Shape,
): Schema<{ [K in keyof Shape]: Infer<Shape[K]> }> {
  return {
    parse(input, path = '') {
      if (typeof input !== 'object' || input === null || Array.isArray(input)) return fail(path, 'object');
      const out: Record<string, unknown> = {};
      for (const [key, schema] of Object.entries(shape)) {
        out[key] = schema.parse((input as Record<string, unknown>)[key], path ? `${path}.${key}` : key);
      }
      // Each property was produced by its own schema, which the loop can't express to the compiler.
      return out as { [K in keyof Shape]: Infer<Shape[K]> };
    },
  };
}
