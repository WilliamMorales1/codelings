// intro1.js
//
// Welcome to weblings! Every exercise in this course is a small piece of code
// whose tests fail.
//
// Each exercise has a spec next door in tests/<chapter>/<name>.test.js (read
// it: tests are the exercise's contract). `node weblings.js watch` runs that
// spec every time you save and tells you what is still wrong. As soon as the
// spec passes, the exercise is done and weblings moves you on.
//
// Task: the spec wants greeting() to say "Hello, weblings!", and
// greeting('rust') to say "Hello, rustlings!". Fix the default and save.

export function greeting(name = "web") {
  return `Hello, ${name}lings!`;
}
