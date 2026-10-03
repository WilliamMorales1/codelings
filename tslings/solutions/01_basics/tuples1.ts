// tuples1 — Tuples
//
// An array literal like [key, 1] is inferred as (string | number)[] — any
// length, any order. A tuple type [string, number] says "exactly two
// elements, a string then a number", which is what a function returning a
// pair means.
//
// The course tsconfig enables `noUncheckedIndexedAccess`: indexing an array
// (or destructuring one) gives `T | undefined`, because the index may be out
// of range. Tuples don't have that problem — their length is known.
//
// Task: give `parseEntry` a tuple return type, and deal with the possibly
// missing pieces of `line.split('=')` (an absent key becomes '').

export function parseEntry(line: string): [key: string, value: number] {
  const [key, value] = line.split('=');
  return [key ?? '', Number(value)];
}

export function total(lines: string[]): number {
  let sum = 0;
  for (const line of lines) {
    const [, n] = parseEntry(line);
    sum += n;
  }
  return sum;
}
