// keyof1 — keyof, typeof and indexed access types
//
// Three operators turn values into types and types into other types:
//
//   typeof theme              the type of a value
//   keyof T                   union of T's keys:   'colors' | 'spacing'
//   T['colors']               the type of one property (an "indexed access")
//   T['spacing'][number]      the element type of an array/tuple property
//
// With a single source of truth (the `theme` object) everything else can be
// derived, so adding a colour needs one edit, not three.
//
// Task: replace the `any`s with types derived from `theme`:
//   ColorName  'primary' | 'danger' | 'muted'
//   Spacing    0 | 4 | 8 | 16
//   Theme      the whole type of theme

export const theme = {
  colors: { primary: '#0066ff', danger: '#e33e33', muted: '#888888' },
  spacing: [0, 4, 8, 16],
} as const;

export type Theme = typeof theme;
export type ColorName = keyof Theme['colors'];
export type Spacing = Theme['spacing'][number];

export function color(name: ColorName): string {
  return theme.colors[name];
}

export function space(n: Spacing): string {
  return `${n}px`;
}
