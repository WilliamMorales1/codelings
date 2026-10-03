// objects1 — Optional and readonly properties
//
//   title?: string      the property may be missing (its type gains | undefined)
//   readonly id: number  the property can't be assigned after creation
//
// Todos here are treated as immutable values: `complete` must return a new
// todo instead of changing the one it was given (the UI compares old and new
// objects to decide what to re-render).
//
// Task:
//   1. Not every todo has a due date — make `dueDate` optional.
//   2. Make every property readonly.
//   3. Fix `complete` so it no longer mutates its argument.

export interface Todo {
  readonly id: number;
  readonly title: string;
  readonly done: boolean;
  readonly dueDate?: string;
}

let nextId = 1;

export function createTodo(title: string): Todo {
  return { id: nextId++, title, done: false };
}

export function complete(todo: Todo): Todo {
  return { ...todo, done: true };
}
