// vite5/vite.config.js -- reference solution.

import { defineConfig } from 'vite';

const target = process.env.API_TARGET ?? 'http://localhost:3001';

export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target,
        changeOrigin: true,
        rewrite: (p) => p.replace(/^\/api/, ''),
      },
    },
  },
});
