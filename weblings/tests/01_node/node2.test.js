import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { afterAll, expect, test } from 'vitest';
import { DEFAULTS, loadConfig, saveConfig } from '@ex/01_node/node2.js';

const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'weblings-node2-'));
afterAll(() => fs.rmSync(dir, { recursive: true, force: true }));

test('a missing file gives a copy of the defaults', async () => {
  const cfg = await loadConfig(path.join(dir, 'nope.json'));
  expect(cfg).toEqual({ theme: 'light', fontSize: 14, plugins: [] });
  expect(cfg).not.toBe(DEFAULTS);
});

test('values in the file override the defaults', async () => {
  const file = path.join(dir, 'partial.json');
  fs.writeFileSync(file, '{ "theme": "dark", "tabs": true }');
  expect(await loadConfig(file)).toEqual({ theme: 'dark', fontSize: 14, plugins: [], tabs: true });
});

test('broken JSON is an error, not silently the defaults', async () => {
  const file = path.join(dir, 'broken.json');
  fs.writeFileSync(file, '{ "theme": ');
  await expect(loadConfig(file)).rejects.toThrow(SyntaxError);
});

test('saveConfig writes pretty JSON into new directories', async () => {
  const file = path.join(dir, 'nested', 'deeper', 'config.json');
  await saveConfig(file, { theme: 'dark', fontSize: 16 });
  expect(fs.readFileSync(file, 'utf8')).toBe('{\n  "theme": "dark",\n  "fontSize": 16\n}\n');
});

test('what saveConfig writes, loadConfig reads back', async () => {
  const file = path.join(dir, 'roundtrip.json');
  await saveConfig(file, { plugins: ['git'] });
  expect(await loadConfig(file)).toEqual({ theme: 'light', fontSize: 14, plugins: ['git'] });
});

/* HINT
`readFile(file, 'utf8')` returns a Promise of a string -- `await` it.
Merge into a *new* object: `{ ...DEFAULTS, ...JSON.parse(text) }`.
In the catch, look at `err.code === 'ENOENT'`; rethrow everything else.
In saveConfig: `await mkdir(path.dirname(file), { recursive: true })`, then
`await writeFile(file, JSON.stringify(config, null, 2) + '\n')`.
*/
