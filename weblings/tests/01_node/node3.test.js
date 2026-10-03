import path from 'node:path';
import { expect, test } from 'vitest';
import { dataPath, fromUrl, splitName, toUrl } from '@ex/01_node/node3.js';
import { exPath } from '../helpers.js';

test('dataPath is relative to the module, not the working directory', () => {
  expect(dataPath('users.json')).toBe(exPath('01_node', 'data', 'users.json'));
  expect(dataPath('img', 'logo.png')).toBe(exPath('01_node', 'data', 'img', 'logo.png'));
});

test('splitName uses the last extension only', () => {
  expect(splitName('/srv/backups/archive.tar.gz')).toEqual({ dir: '/srv/backups', name: 'archive.tar', ext: '.gz' });
});

test('splitName copes with no extension and dotfiles', () => {
  expect(splitName('Makefile')).toEqual({ dir: '', name: 'Makefile', ext: '' });
  expect(splitName('/home/me/.bashrc')).toEqual({ dir: '/home/me', name: '.bashrc', ext: '' });
});

test('toUrl resolves relative paths and escapes', () => {
  expect(toUrl('/tmp/my notes #1.txt')).toBe('file:///tmp/my%20notes%20%231.txt');
  expect(toUrl('notes.txt')).toBe('file://' + path.resolve('notes.txt'));
});

test('fromUrl decodes back to the original path', () => {
  expect(fromUrl('file:///tmp/my%20notes%20%231.txt')).toBe('/tmp/my notes #1.txt');
  expect(fromUrl(toUrl('/tmp/100%.txt'))).toBe('/tmp/100%.txt');
});

/* HINT
`path.join(import.meta.dirname, 'data', ...parts)` for dataPath.
`path.parse(file)` already returns { root, dir, base, name, ext }.
`pathToFileURL(path.resolve(file)).href` and `fileURLToPath(url)` come from
`node:url`.
*/
