// vite3/vite.config.js
//
// Public base path and build options
//
// By default Vite assumes the site is served from `/`. If it will live at
// https://example.com/app/ instead, set `base: '/app/'` and every asset URL in
// the output gets that prefix. The `build` section shapes the output:
// `assetsDir` (the folder for JS/CSS inside outDir), `sourcemap`, and
// `manifest` (a .vite/manifest.json mapping source files to hashed output,
// used by backends that render their own HTML).
//
// Task: configure the build so that
//   - assets are served from /app/
//   - JS and CSS land in static/ instead of assets/
//   - every JS file gets a .map next to it
//   - .vite/manifest.json is written
// (The test chooses outDir itself, so leave that one alone.)

import { defineConfig } from 'vite';

export default defineConfig({
  build: {
    // TODO
  },
});
