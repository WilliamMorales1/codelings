// node2.js
//
// Files and JSON with fs/promises
//
// `node:fs/promises` gives you promise-returning versions of the fs calls:
// `readFile(path, 'utf8')`, `writeFile`, `mkdir(dir, { recursive: true })`.
// Forget the encoding and you get a Buffer; forget `await` and you get a
// Promise. Both are easy to miss because nothing complains until later.
//
// Task: fix the config loader.
//   - loadConfig(file) returns DEFAULTS merged with the JSON in `file`.
//     A missing file (ENOENT) means "use the defaults"; any other error,
//     including broken JSON, must reach the caller. DEFAULTS itself must
//     never be modified.
//   - saveConfig(file, config) writes pretty JSON (2-space indent, trailing
//     newline), creating parent directories as needed, and only resolves
//     once the file is on disk.

import { mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';

export const DEFAULTS = Object.freeze({ theme: 'light', fontSize: 14, plugins: [] });

export async function loadConfig(file) {
  try {
    const text = readFile(file);
    return Object.assign(DEFAULTS, JSON.parse(text));
  } catch {
    return DEFAULTS;
  }
}

export async function saveConfig(file, config) {
  writeFile(file, JSON.stringify(config));
}
