// enums1 — Enums versus const objects
//
// `enum` is one of the few TypeScript features that generates JavaScript
// code. That means tools that only *strip* types can't handle it: Node's
// built-in TypeScript support (`node file.ts`) rejects enums with
// ERR_UNSUPPORTED_TYPESCRIPT_SYNTAX, and the `erasableSyntaxOnly` compiler
// option forbids them. Numeric enums also produce 0, 1, 2 in your logs.
//
// The modern replacement: a plain object `as const`, plus a type derived
// from its values.
//
// Task: rewrite LogLevel as a const object whose values are the strings
// 'debug', 'info', 'warn', 'error', and a type `LogLevel` that is the union
// of those strings. Keep `LogLevel.Warn` working for callers, and make
// `shouldLog` accept plain strings like 'warn' too. The test also checks the
// file can be run by Node's type stripping.

export const LogLevel = {
  Debug: 'debug',
  Info: 'info',
  Warn: 'warn',
  Error: 'error',
} as const;

// A value and a type may share a name; TypeScript knows which one you mean from where it's used.
export type LogLevel = (typeof LogLevel)[keyof typeof LogLevel];

const order: LogLevel[] = [LogLevel.Debug, LogLevel.Info, LogLevel.Warn, LogLevel.Error];

export function shouldLog(level: LogLevel, threshold: LogLevel): boolean {
  return order.indexOf(level) >= order.indexOf(threshold);
}
