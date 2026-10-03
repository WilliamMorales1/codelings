// node3.js -- reference solution.

import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

export function dataPath(...parts) {
  return path.join(import.meta.dirname, 'data', ...parts);
}

export function splitName(file) {
  const { dir, name, ext } = path.parse(file);
  return { dir, name, ext };
}

export function toUrl(file) {
  return pathToFileURL(path.resolve(file)).href;
}

export function fromUrl(url) {
  return fileURLToPath(url);
}
