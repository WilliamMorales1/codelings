const noColor = () => process.env.NO_COLOR !== undefined;

const codes = { bold: 1, dim: 2, red: 31, green: 32, yellow: 33, blue: 34, cyan: 36 };

export const paint = (style, s) => (noColor() ? s : `\x1b[${codes[style]}m${s}\x1b[0m`);
export const say = (style, s) => console.log(paint(style, s));

export const padTo = (s, n) => s + ' '.repeat(Math.max(0, n - s.length));

// OSC 8 hyperlink; suppressed under NO_COLOR for terminals that print escapes literally.
export function fileLink(abs, label) {
  if (noColor()) return label;
  return `\x1b]8;;file://${abs}\x1b\\${label}\x1b]8;;\x1b\\`;
}

export const clearScreen = () => process.stdout.write('\x1b[2J\x1b[3J\x1b[H');

export function progressBar(done, total) {
  const width = 32;
  const filled = total === 0 ? 0 : Math.floor((width * done) / total);
  const bar = paint('green', '#'.repeat(filled)) + '-'.repeat(width - filled);
  return `Progress: [${bar}] ${done}/${total}`;
}

export function indent(text, pad = '    ') {
  return text
    .replace(/\s+$/, '')
    .split('\n')
    .map((l) => pad + l)
    .join('\n');
}
