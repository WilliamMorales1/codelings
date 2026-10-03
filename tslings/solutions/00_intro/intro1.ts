// intro1 — Welcome to tslings!
//
// Every exercise is a TypeScript file that is broken in some way. An exercise
// passes when BOTH of these are true:
//
//   1. it typechecks under the strict tsconfig.json at the root of the course
//      (the same one your editor uses, so red squiggles = failures), and
//   2. its test file in tests/<chapter>/<name>.test.ts passes under vitest.
//
// Once it passes, it is marked done and tslings moves you on. Keep
// `node tslings.ts watch` running in a second terminal; it re-checks every
// time you save.
//
// Task: the test wants greet('Ada') to return "Hello, Ada!". Fix it and save.

export function greet(name: string): string {
  return `Hello, ${name}!`;
}
