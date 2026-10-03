// dts1 — A .d.ts file for an untyped JavaScript module
//
// This exercise is a directory. slugify.js is a plain JavaScript module (you
// don't need to change it). Without type information, importing it from
// TypeScript is an error (TS7016: "Could not find a declaration file").
//
// A declaration file sitting next to it, slugify.d.ts, describes its exports
// with types and no implementations:
//
//   export declare function f(x: string): number;
//   export interface Opts { ... }
//
// That's exactly what DefinitelyTyped's @types/* packages are.
//
// Task: write slugify.d.ts. Read the JavaScript to find out what the
// function accepts and returns. Export the options as an interface named
// SlugifyOptions, with every option optional.

/**
 * Turns "Hello, World!" into "hello-world".
 * options.separator: string placed between words (default "-")
 * options.lower: lower-case the result (default true)
 * options.maxLength: cut the slug to at most this many characters
 */
export function slugify(text, options = {}) {
  const { separator = '-', lower = true, maxLength } = options;
  let slug = text
    .normalize('NFKD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^A-Za-z0-9]+/g, ' ')
    .trim()
    .split(/\s+/)
    .join(separator);
  if (lower) slug = slug.toLowerCase();
  if (maxLength !== undefined) slug = slug.slice(0, maxLength);
  return slug;
}

export const version = '1.2.0';
