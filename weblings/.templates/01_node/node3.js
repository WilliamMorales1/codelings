// node3.js
//
// Paths and file URLs
//
// ES modules have no `__dirname`. Use `import.meta.dirname` (the directory of
// the current module) and `import.meta.filename`, or `import.meta.url`, which
// is a file:// URL. Build paths with `node:path` rather than gluing strings,
// and convert between paths and URLs with `pathToFileURL` / `fileURLToPath`
// from `node:url` -- they handle spaces, `%` and other characters that a
// string replace gets wrong.
//
// Task: fix all four helpers.
//   - dataPath(...parts): absolute path to `data/<parts...>` next to this file
//   - splitName(file): { dir, name, ext }, where `archive.tar.gz` has ext `.gz`,
//     `Makefile` has ext '', and `.bashrc` is all name
//   - toUrl(file): file:// URL string for a (possibly relative) path
//   - fromUrl(url): the path back from a file:// URL

import path from 'node:path';

export function dataPath(...parts) {
  return __dirname + '/data/' + parts.join('/');
}

export function splitName(file) {
  const base = file.split('/').pop();
  return {
    dir: file.split('/').slice(0, -1).join('/'),
    name: base.split('.')[0],
    ext: '.' + base.split('.').pop(),
  };
}

export function toUrl(file) {
  return 'file://' + file;
}

export function fromUrl(url) {
  return url.replace('file://', '');
}
