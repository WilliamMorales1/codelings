// interfaces1 — interface extends versus type intersection
//
// Both of these add fields to Timestamps:
//
//   type Post = Timestamps & { title: string }
//   interface Post extends Timestamps { title: string }
//
// They differ when the two sides disagree about a property. An intersection
// silently intersects the property types (Date & string — a type no value
// has), and you find out later with a baffling error at some use site.
// `extends` reports the conflict right at the declaration.
//
// Task: rewrite Post as an interface that extends Timestamps, read the error
// it gives, and resolve the conflict: timestamps are Dates.
//

export type Timestamps = { createdAt: Date; updatedAt: Date };

export type Post = Timestamps & {
  title: string;
  createdAt: string;
};

export function makePost(title: string): Post {
  const now = new Date();
  return { title, createdAt: now.toISOString(), updatedAt: now };
}
