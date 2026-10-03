import { stripTypeScriptTypes } from 'node:module';
import { expect, it } from 'vitest';
import { label, seeded, type User } from '@ex/07_classes_modules/import_type1/report.ts';
import { exerciseSource } from '../helpers.ts';

it('works', () => {
  const ada: User = { id: 1, name: 'Ada' };
  expect(label(ada, 'admin')).toBe('Ada (admin)');
  expect(seeded().all()).toEqual([ada]);
});

it('type imports vanish when types are stripped', () => {
  const js = stripTypeScriptTypes(exerciseSource('07_classes_modules/import_type1/report.ts'));
  const imports = js.split('\n').filter((l) => /^\s*(import|export)\b.*from|^\s*export \{/.test(l));
  expect(imports.join('\n')).not.toMatch(/\bUser\b(?!Repo)|\bRole\b/);
  expect(imports.join('\n')).toMatch(/UserRepo/);
});

/* HINT
  import { type Role, type User, UserRepo } from './models.ts';
  export type { User };
UserRepo is a class — a real runtime value (`new UserRepo()`) — so it stays a
normal import. Role and User exist only for the type checker.
*/
