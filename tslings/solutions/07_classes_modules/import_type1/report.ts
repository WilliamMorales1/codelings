// import_type1 — see models.ts for the explanation.

import { type Role, type User, UserRepo } from './models.ts';

export type { User };

export function label(user: User, role: Role): string {
  return `${user.name} (${role})`;
}

export function seeded(): UserRepo {
  const repo = new UserRepo();
  repo.add({ id: 1, name: 'Ada' });
  return repo;
}
