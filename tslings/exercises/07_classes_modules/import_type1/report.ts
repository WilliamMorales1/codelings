// import_type1 — see models.ts for the explanation.
//

import { Role, User, UserRepo } from './models.ts';

export { User };

export function label(user: User, role: Role): string {
  return `${user.name} (${role})`;
}

export function seeded(): UserRepo {
  const repo = new UserRepo();
  repo.add({ id: 1, name: 'Ada' });
  return repo;
}
