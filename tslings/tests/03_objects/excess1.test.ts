import { expect, it } from 'vitest';
import { dev, prod } from '@ex/03_objects/excess1.ts';
import { exerciseSource } from '../helpers.ts';

it('starts dev', () => {
  expect(dev).toBe('localhost:3000 (verbose)');
});

it('starts prod', () => {
  expect(prod).toBe('example.com:443');
});

it('annotates the options variable so typos are caught', () => {
  expect(exerciseSource('03_objects/excess1.ts')).toMatch(/const prodOptions\s*:\s*ServerOptions\b/);
});

/* HINT
The first error names the typo. The second has no error at all — that's
the point. Annotate the variable: `const prodOptions: ServerOptions = {...}`;
now the literal is checked against ServerOptions and `hostname` is flagged.
(`{ ... } satisfies ServerOptions` works too, but the test looks for the
annotation.)
*/
