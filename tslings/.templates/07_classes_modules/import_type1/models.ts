// import_type1 — `import type`
//
// This exercise is a directory: models.ts and report.ts.
//
// The course tsconfig sets `verbatimModuleSyntax`: every import you write
// stays in the JavaScript output exactly as written, and only imports marked
// as types are erased. That's what makes files safe for tools that
// transpile one file at a time (Node's type stripping, esbuild, Vite): they
// can't know that `User` is "only a type" unless you say so.
//
//   import type { User } from './models.ts';          whole import erased
//   import { type User, Repo } from './models.ts';    just User erased
//   export type { User } from './models.ts';          type-only re-export
//
// Task: fix the imports and exports in report.ts (not this file).

export interface User {
  id: number;
  name: string;
}

export type Role = 'admin' | 'member';

export class UserRepo {
  #users: User[] = [];

  add(user: User): void {
    this.#users.push(user);
  }

  all(): readonly User[] {
    return this.#users;
  }
}
