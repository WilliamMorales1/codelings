// vite5/vite.config.js
//
// Dev server proxy
//
// In development the frontend runs on Vite's dev server and the API on some
// other port. Instead of fighting CORS, let the dev server forward API calls:
// `server.proxy` maps a path prefix to a target. The long form takes options:
//     '/api': {
//       target: 'http://localhost:3001',
//       changeOrigin: true,                         // Host header = the target's
//       rewrite: (p) => p.replace(/^\/api/, ''),    // strip the prefix
//     }
// The proxy only exists in `vite` (dev) -- a production build needs a real
// reverse proxy doing the same job.
//
// Task: the backend serves /users, /users/1, ... (no /api prefix) and checks
// the Host header. Forward /api/* to it so that /api/users?limit=2 reaches
// the backend as /users?limit=2 with the backend's own host. The backend's
// address comes from $API_TARGET (the test sets it).
// Try it with any backend: `API_TARGET=http://localhost:3001 npx vite exercises/03_vite/vite5`

import { defineConfig } from 'vite';

const target = process.env.API_TARGET ?? 'http://localhost:3001';

export default defineConfig({
  server: {
    proxy: {
      '/api': target,
    },
  },
});
