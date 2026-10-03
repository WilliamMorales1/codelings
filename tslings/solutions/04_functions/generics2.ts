// generics2 — Default type arguments
//
// Type parameters can have defaults, like function parameters:
//
//   interface Box<T = unknown> { value: T }
//   let b: Box;             // Box<unknown>
//
// Without a default, every mention of the type must supply the argument,
// even code that doesn't care about it (like a logger that only reads the
// status).
//
// Task:
//   - `ApiResponse` without an argument should mean ApiResponse<unknown>.
//   - Most pages use string cursors: `Page<Item>` should mean
//     Page<Item, string>, while Page<Item, number> still works.

export interface ApiResponse<T = unknown> {
  status: number;
  data: T;
}

export function logStatus(response: ApiResponse): string {
  return `HTTP ${response.status}`;
}

export interface Page<Item, Cursor = string> {
  items: Item[];
  next: Cursor | null;
}

export function firstPage(): Page<number> {
  return { items: [1, 2, 3], next: 'cursor-2' };
}
