// node2.js -- reference solution.

import { mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';

export const DEFAULTS = Object.freeze({ theme: 'light', fontSize: 14, plugins: [] });

export async function loadConfig(file) {
  try {
    const text = await readFile(file, 'utf8');
    return { ...DEFAULTS, ...JSON.parse(text) };
  } catch (err) {
    if (err.code === 'ENOENT') return { ...DEFAULTS };
    throw err;
  }
}

export async function saveConfig(file, config) {
  await mkdir(path.dirname(file), { recursive: true });
  await writeFile(file, JSON.stringify(config, null, 2) + '\n');
}
