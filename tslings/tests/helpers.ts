import fs from 'node:fs';
import path from 'node:path';

/** exerciseSource reads an exercise file as text, from wherever the runner points `@ex` (see vitest.config.ts). */
export function exerciseSource(rel: string): string {
  return fs.readFileSync(path.resolve(import.meta.dirname, '..', process.env.TSLINGS_SRC ?? 'exercises', rel), 'utf8');
}
