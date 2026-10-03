// functions1 — Optional, default and rest parameters
//
//   function f(a: string, b?: string)       b may be omitted (string | undefined)
//   function f(a: string, b = 'hi')          b may be omitted; type inferred from default
//   function f(...nums: number[])            any number of arguments, as an array
//
// TypeScript checks the *number* of arguments too: calling a two-parameter
// function with one argument is an error, even though JavaScript allows it.
//
// Task: the test calls these functions the way callers actually want to.
// Change the parameter lists (not the test) so those calls compile and work:
//   greet('Ada')                        -> 'Hello, Ada!'
//   greet('Ada', 'Welcome')             -> 'Welcome, Ada!'
//   sum(1, 2, 3)                        -> 6   (and sum() -> 0)
//   fullName('Ada', 'Lovelace')         -> 'Ada Lovelace'
//   fullName('Ada', 'Lovelace', 'King') -> 'Ada King Lovelace'
//

export function greet(name: string, greeting: string): string {
  return `${greeting}, ${name}!`;
}

export function sum(nums: number[]): number {
  return nums.reduce((a, b) => a + b, 0);
}

export function fullName(first: string, last: string, middle: string): string {
  return [first, middle, last].join(' ');
}
