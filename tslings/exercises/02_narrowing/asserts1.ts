// asserts1 — Assertion functions
//
// A type guard narrows inside an `if`. An *assertion function* narrows
// everything after the call, by throwing when the condition is false:
//
//   function assert(cond: unknown, msg: string): asserts cond { ... }
//   function assertIsDefined<T>(v: T): asserts v is NonNullable<T> { ... }
//
// A plain `void` return type does the throwing but tells the compiler
// nothing, so `raw` below is still `string | undefined` after the check.
//
// Task: give both helpers assertion signatures so `parsePort` compiles.
//

export function assert(condition: unknown, message: string): void {
  if (!condition) throw new Error(message);
}

export function assertIsDefined<T>(value: T, name: string): void {
  if (value === undefined || value === null) throw new Error(`${name} is not set`);
}

export function parsePort(env: Record<string, string | undefined>): number {
  const raw = env.PORT;
  assertIsDefined(raw, 'PORT');
  const port = Number.parseInt(raw, 10);
  assert(Number.isInteger(port) && port > 0 && port < 65536, `bad PORT: ${raw}`);
  return port;
}
