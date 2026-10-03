// vite4/vite.config.js
//
// Import aliases with resolve.alias
//
// Deep relative imports like '../../../utils/format.js' are fragile. An alias
// maps a prefix to a directory: with `'@': <abs path of src>`,
// `import '@/utils/format.js'` means src/utils/format.js from anywhere.
// Alias targets should be absolute paths -- a relative one is pasted into the
// import as-is and then resolved relative to the importing file. In an ES
// module config, `fileURLToPath(new URL('./src', import.meta.url))` or
// `path.resolve(import.meta.dirname, 'src')` gives you one.
//
// Task: src/main.js imports from '@/...' and '@components/...'. Add aliases
// so that '@' points at src/ and '@components' at src/components/.

import { defineConfig } from 'vite';

export default defineConfig({
  resolve: {
    alias: {
      '@': './src',
    },
  },
});
