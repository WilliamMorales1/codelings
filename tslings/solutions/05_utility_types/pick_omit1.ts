// pick_omit1 — Pick and Omit
//
//   Pick<User, 'id' | 'name'>      only those properties
//   Omit<User, 'id' | 'createdAt'> everything but those
//
// Hand-copied types drift: someone renamed `name` to `displayName` in User,
// and the copies below were never updated. Derived types can't drift — they
// change when User changes.
//
// Task: define UserPreview (just id and displayName) and NewUser (everything
// except the server-assigned id and createdAt) in terms of User, and fix the
// functions to match.

export interface User {
  id: number;
  displayName: string;
  email: string;
  createdAt: Date;
}

export type UserPreview = Pick<User, 'id' | 'displayName'>;

export type NewUser = Omit<User, 'id' | 'createdAt'>;

export function toPreview(u: User): UserPreview {
  return { id: u.id, displayName: u.displayName };
}

let nextId = 1;
export function createUser(input: NewUser): User {
  return { ...input, id: nextId++, createdAt: new Date() };
}
