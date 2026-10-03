// record1 — Record
//
// `Record<K, V>` is an object type with exactly the keys K, each holding a V.
// With a union of literal keys it becomes a checklist: leave one out and
// the compiler complains. A loose `{ [key: string]: string }` would accept
// any keys, including none.
//
// Someone added 'archived' to Status and forgot the label. Nothing warned
// them — the badge just rendered "undefined".
//
// Task: type `labels` so a missing (or misspelled) status is a compile
// error, then add the missing label: 'Archived'.
//

export type Status = 'draft' | 'published' | 'archived';

export const labels: { [key: string]: string } = {
  draft: 'Draft',
  published: 'Published',
};

export function badge(status: Status): string {
  return `[${labels[status]}]`;
}
