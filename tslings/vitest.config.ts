import path from 'node:path';
import { defineConfig } from 'vitest/config';

// scripts/verify-all.sh points the same tests at solutions/ or a stripped copy of exercises/.
const src = path.resolve(import.meta.dirname, process.env.TSLINGS_SRC ?? 'exercises');

export default defineConfig({
  resolve: { alias: { '@ex': src } },
  test: {
    include: ['tests/**/*.test.ts'],
    // Type checking is done by tsc in the runner, not by vitest.
    typecheck: { enabled: false },
    testTimeout: 10_000,
  },
});
