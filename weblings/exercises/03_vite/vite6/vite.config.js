// vite6/vite.config.js
//
// Writing a plugin: virtual modules
//
// A Vite plugin is an object with a `name` and hooks. Two hooks are enough to
// invent a module that exists nowhere on disk:
//   - resolveId(id): claim the import. Return a resolved id (by convention
//     '\0' + id, which tells other plugins "not a real file, hands off"), or
//     nothing to let someone else resolve it.
//   - load(id): given a resolved id you claimed, return the module's source
//     code as a string.
// `configResolved(config)` runs once the final config is known, e.g. to read
// `config.mode` ('production' for `vite build`, or whatever --mode says).
//
// Task: make `import { version, mode } from 'virtual:build-info'` work.
// `version` is the string passed to buildInfo(), `mode` is the build mode.
// Remember the module source is *code*: string values need quotes
// (JSON.stringify does that for you).

import { defineConfig } from 'vite';

export function buildInfo({ version }) {
  const virtualId = 'virtual:build-info';
  let mode;

  return {
    name: 'build-info',
    resolveId(id) {
      if (id === virtualId) return id;
    },
    load(id) {
      if (id === 'build-info') {
        return `export const version = ${version};\nexport const mode = ${mode};`;
      }
    },
  };
}

export default defineConfig({
  plugins: [buildInfo({ version: '1.4.2' })],
});
