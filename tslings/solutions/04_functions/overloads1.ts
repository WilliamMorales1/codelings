// overloads1 — Function overloads
//
// `parse` turns a string into a number and an array of strings into an array
// of numbers. Its single signature says it returns `number | number[]`, so
// every caller has to check which one it got — even though the answer is
// obvious from the argument.
//
// Overloads list several call signatures above one implementation:
//
//   function f(x: string): number;
//   function f(x: string[]): number[];
//   function f(x: string | string[]): number | number[] { ...implementation... }
//
// Callers see only the overloads; the implementation signature is hidden
// and must be compatible with all of them.
//
// Task: add overloads so the return type follows the argument type.

export function parse(input: string): number;
export function parse(input: string[]): number[];
export function parse(input: string | string[]): number | number[] {
  if (Array.isArray(input)) return input.map((s) => Number(s));
  return Number(input);
}

export function double(input: string): number {
  return parse(input) * 2;
}
