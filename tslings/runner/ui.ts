const noColor = (): boolean => process.env.NO_COLOR !== undefined;

const codes = { bold: 1, dim: 2, red: 31, green: 32, yellow: 33, blue: 34, cyan: 36 } as const;
export type Style = keyof typeof codes;

export const paint = (style: Style, s: string): string => (noColor() ? s : `\x1b[${codes[style]}m${s}\x1b[0m`);
export const say = (style: Style, s: string): void => console.log(paint(style, s));

export const padTo = (s: string, n: number): string => s + ' '.repeat(Math.max(0, n - s.length));

// OSC 8 hyperlink; suppressed under NO_COLOR for terminals that print escapes literally.
export function fileLink(abs: string, label: string, line?: number): string {
  if (noColor()) return label;
  return `\x1b]8;;file://${abs}${line ? `#${line}` : ''}\x1b\\${label}\x1b]8;;\x1b\\`;
}

export const clearScreen = (): void => {
  process.stdout.write('\x1b[2J\x1b[3J\x1b[H');
};

export function progressBar(done: number, total: number): string {
  const width = 32;
  const filled = total === 0 ? 0 : Math.floor((width * done) / total);
  const bar = paint('green', '#'.repeat(filled)) + '-'.repeat(width - filled);
  return `Progress: [${bar}] ${done}/${total}`;
}

export function indent(text: string, pad = '    '): string {
  return text
    .replace(/\s+$/, '')
    .split('\n')
    .map((l) => pad + l)
    .join('\n');
}
