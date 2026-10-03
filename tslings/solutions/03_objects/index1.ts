// index1 — Index signatures
//
// `{ [word: string]: number }` describes an object used as a dictionary: any
// string key, number values. `Record<string, number>` is the same thing.
//
// The course tsconfig turns on `noUncheckedIndexedAccess`, so reading
// `counts[word]` gives `number | undefined` — the key might not be there.
// Without that flag TypeScript would claim `number`, and `undefined + 1`
// would quietly produce NaN.
//
// Task: make `countWords` and `countOf` compile and behave; a missing word
// counts as 0. Ignore empty strings produced by leading/trailing spaces.

export interface WordCounts {
  [word: string]: number;
}

export function countWords(text: string): WordCounts {
  const counts: WordCounts = {};
  for (const word of text.toLowerCase().split(/\s+/)) {
    if (word === '') continue;
    counts[word] = (counts[word] ?? 0) + 1;
  }
  return counts;
}

export function countOf(counts: WordCounts, word: string): number {
  return counts[word] ?? 0;
}
