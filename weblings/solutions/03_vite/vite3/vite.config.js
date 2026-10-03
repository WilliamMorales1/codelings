// vite3/vite.config.js -- reference solution.

import { defineConfig } from 'vite';

export default defineConfig({
  base: '/app/',
  build: {
    assetsDir: 'static',
    sourcemap: true,
    manifest: true,
  },
});
