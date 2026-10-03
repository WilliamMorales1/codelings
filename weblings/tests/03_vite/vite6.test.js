import { afterAll, expect, test } from 'vitest';
import { buildInfo } from '@ex/03_vite/vite6/vite.config.js';
import { viteBuild } from '../helpers.js';

const builds = [];
afterAll(() => builds.forEach((b) => b.cleanup()));

async function build(mode) {
  try {
    const out = await viteBuild('vite6', { mode });
    builds.push(out);
    return out;
  } catch (e) {
    throw new Error(`vite build failed:\n${e.message.split('\n').slice(0, 4).join('\n')}`);
  }
}

test('resolveId claims only the virtual id, with the \\0 prefix', () => {
  const plugin = buildInfo({ version: '0.0.1' });
  expect(plugin.resolveId('virtual:build-info')).toBe('\0virtual:build-info');
  expect(plugin.resolveId('./main.js')).toBeUndefined();
});

test('load returns valid module code with the version', async () => {
  const plugin = buildInfo({ version: '0.0.1' });
  plugin.configResolved?.({ mode: 'test' });
  const code = plugin.load('\0virtual:build-info');
  expect(typeof code).toBe('string');
  const url = 'data:text/javascript,' + encodeURIComponent(code);
  const mod = await import(/* @vite-ignore */ url);
  expect(mod.version).toBe('0.0.1');
  expect(mod.mode).toBe('test');
  expect(plugin.load('/some/real/file.js')).toBeUndefined();
});

test('a production build bakes in version and mode', async () => {
  const js = (await build('production')).js();
  expect(js).toContain('1.4.2');
  expect(js).toContain('production');
});

test('--mode is respected', async () => {
  expect((await build('staging')).js()).toContain('staging');
});

/* HINT
resolveId should `return '\0' + virtualId` for the virtual id, and load should
compare against that same '\0' id.
Grab the mode in a `configResolved(config) { mode = config.mode; }` hook, and
build the code with JSON.stringify:
    `export const version = ${JSON.stringify(version)};` ...
*/
