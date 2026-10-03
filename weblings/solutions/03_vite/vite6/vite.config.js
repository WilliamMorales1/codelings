// vite6/vite.config.js -- reference solution.

import { defineConfig } from 'vite';

export function buildInfo({ version }) {
  const virtualId = 'virtual:build-info';
  const resolvedId = '\0' + virtualId;
  let mode;

  return {
    name: 'build-info',
    configResolved(config) {
      mode = config.mode;
    },
    resolveId(id) {
      if (id === virtualId) return resolvedId;
    },
    load(id) {
      if (id === resolvedId) {
        return `export const version = ${JSON.stringify(version)};\nexport const mode = ${JSON.stringify(mode)};`;
      }
    },
  };
}

export default defineConfig({
  plugins: [buildInfo({ version: '1.4.2' })],
});
