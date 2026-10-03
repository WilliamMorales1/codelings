import path from 'node:path';
import { defineConfig } from 'vitest/config';

// scripts/verify-all.sh points the same tests at solutions/ or a stripped copy of exercises/.
const src = path.resolve(import.meta.dirname, process.env.WEBLINGS_SRC ?? 'exercises');

export default defineConfig({
  resolve: { alias: { '@ex': src } },
  test: {
    include: ['tests/**/*.test.{js,jsx}'],
    // ES modules outside vitest have no __dirname/require; keep the exercises honest.
    injectCjsGlobals: false,
    testTimeout: 15_000,
    hookTimeout: 30_000,
  },
});
