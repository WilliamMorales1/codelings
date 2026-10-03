import fs from 'node:fs';
import path from 'node:path';

const ROOT = path.resolve(import.meta.dirname, '..');

/** sourcesOf returns an exercise's HTML file and CSS entry (null when the exercise has no stylesheet of its own). */
export function sourcesOf(exPath) {
  if (fs.statSync(exPath).isDirectory()) {
    const css = path.join(exPath, 'style.css');
    return { html: path.join(exPath, 'index.html'), css: fs.existsSync(css) ? css : null, base: exPath };
  }
  return { html: exPath, css: null, base: path.dirname(exPath) };
}

// Single-file exercises share a chapter directory, so they only scan their own file.
const implicitEntry = (html) => `@import "tailwindcss" source(none);\n@source "./${path.basename(html)}";\n`;

// Resolve `tailwindcss` from the course, so stripped copies outside the repo still compile.
async function cssResolver(id) {
  if (id !== 'tailwindcss' && !id.startsWith('tailwindcss/')) return undefined;
  const sub = id === 'tailwindcss' ? 'index.css' : id.slice('tailwindcss/'.length);
  for (const cand of [sub, `${sub}.css`]) {
    const p = path.join(ROOT, 'node_modules', 'tailwindcss', cand);
    if (fs.existsSync(p)) return p;
  }
  return undefined;
}

/** buildCss compiles an exercise the way the Tailwind CLI would: scan sources, generate, then optimize with Lightning CSS. */
export async function buildCss(exPath, { minify = false } = {}) {
  const { compile, optimize } = await import('@tailwindcss/node');
  const { Scanner } = await import('@tailwindcss/oxide');
  const { html, css, base } = sourcesOf(exPath);
  const input = css ? fs.readFileSync(css, 'utf8') : implicitEntry(html);
  const from = css ?? path.join(base, '__entry.css');
  const compiler = await compile(input, { base, from, onDependency() {}, customCssResolver: cssResolver });
  const sources = (
    compiler.root === 'none' ? [] : compiler.root === null ? [{ base, pattern: '**/*', negated: false }] : [{ ...compiler.root, negated: false }]
  ).concat(compiler.sources);
  const candidates = new Scanner({ sources }).scan();
  const raw = compiler.build(candidates);
  return { css: optimize(raw, { file: from, minify }).code, html, entry: css, candidates };
}

let defaults = null;

/** defaultTheme returns every variable of Tailwind's default theme, formatted the way buildCss emits them. */
export function defaultTheme() {
  defaults ??= (async () => {
    const { compile, optimize } = await import('@tailwindcss/node');
    const input = '@import "tailwindcss/theme.css" theme(static);\n';
    const compiler = await compile(input, { base: ROOT, from: path.join(ROOT, '__theme.css'), onDependency() {}, customCssResolver: cssResolver });
    const css = optimize(compiler.build([]), { minify: false }).code;
    const vars = new Map();
    for (const m of css.matchAll(/(--[\w-]+):((?:[^;{}()]|\([^()]*(?:\([^()]*\)[^()]*)*\))*)[;}]/g)) vars.set(m[1], m[2].replace(/\s+/g, ' ').trim());
    return vars;
  })();
  return defaults;
}
