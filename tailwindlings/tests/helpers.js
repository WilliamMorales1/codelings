import fs from 'node:fs';
import path from 'node:path';
import { JSDOM } from 'jsdom';
import { buildCss, defaultTheme } from '../runner/tailwind.js';
import { Sheet, Styles, splitTop, toNumber } from './cascade.js';

export const ROOT = path.resolve(import.meta.dirname, '..');
// scripts/verify-all.sh points the tests at solutions/ or a stripped copy of exercises/.
export const SRC = path.resolve(ROOT, process.env.TAILWINDLINGS_SRC ?? 'exercises');

/** exPath returns the exercise file or directory for `chapter/name`. */
export function exPath(id) {
  const [chapter, name] = id.split('/');
  const dir = path.join(SRC, chapter);
  for (const cand of [name, `${name}.html`]) if (fs.existsSync(path.join(dir, cand))) return path.join(dir, cand);
  throw new Error(`exercise ${id} is missing (try \`tailwindlings reset ${name}\`)`);
}

export const readEx = (id, file) => {
  const p = exPath(id);
  return fs.readFileSync(file ? path.join(p, file) : fs.statSync(p).isDirectory() ? path.join(p, 'index.html') : p, 'utf8');
};

/** Page is an exercise compiled by Tailwind and parsed into a DOM. */
export class Page {
  constructor(built, defaults) {
    this.defaults = defaults;
    this.css = built.css;
    this.candidates = built.candidates;
    this.dom = new JSDOM(fs.readFileSync(built.html, 'utf8'));
    this.document = this.dom.window.document;
    this.sheet = new Sheet(this.css);
    this.envs = new Map();
  }

  /** refresh drops cached styles; call it after changing the DOM (checking a box, setting an attribute). */
  refresh() {
    this.envs.clear();
  }

  $(sel) {
    const el = this.document.querySelector(sel);
    if (!el) throw new Error(`the page has no element matching \`${sel}\` (did you change the markup the test relies on?)`);
    return el;
  }

  $$(sel) {
    return [...this.document.querySelectorAll(sel)];
  }

  /**
   * style returns the resolved style of an element.
   * env: width/height (px viewport), scheme ('light'|'dark'), hover/focus/focusVisible/active (selector or element),
   * container (px width of @container ancestors, or read from their data-width), reducedMotion, touch.
   */
  style(target, env = {}) {
    const el = typeof target === 'string' ? this.$(target) : target;
    const key = JSON.stringify(env, (k, v) => (v && v.nodeType ? `node:${indexOf(v)}` : typeof v === 'function' ? String(v) : v));
    if (!this.envs.has(key)) this.envs.set(key, new Styles(this.sheet, this.document, env));
    return this.envs.get(key).of(el);
  }

  /** get is shorthand for style(target, env).get(prop). */
  get(target, prop, env) {
    return this.style(target, env).get(prop);
  }

  /** num is shorthand for style(target, env).num(prop): px for lengths, ms for times, deg for angles. */
  num(target, prop, env) {
    return this.style(target, env).num(prop);
  }

  /** theme returns a theme variable: the page's own value if emitted, else Tailwind's default. */
  theme(name) {
    const v = this.get('html', name) ?? this.defaults.get(name);
    if (v === undefined) throw new Error(`no theme variable ${name}`);
    return v;
  }

  /** hasRule reports whether some generated rule's selector contains `fragment`. */
  hasRule(fragment) {
    return this.sheet.rules.some((r) => r.source.includes(fragment));
  }

  classes(sel) {
    return [...this.$(sel).classList];
  }
}

function indexOf(node) {
  let i = 0;
  for (let n = node; n; n = n.previousElementSibling ?? n.parentElement) i++;
  return i;
}

const cache = new Map();

/** load compiles an exercise and parses its HTML; compiled once per test file. */
export async function load(id) {
  if (!cache.has(id)) cache.set(id, Promise.all([buildCss(exPath(id)), defaultTheme()]).then(([b, d]) => new Page(b, d)));
  return cache.get(id);
}

/** color normalizes hex / rgb() colors to lowercase #rrggbb[aa] so equivalent spellings compare equal. */
export function color(v) {
  if (v == null) return v;
  let s = String(v).trim().toLowerCase();
  let m = /^#([0-9a-f]{3,8})$/.exec(s);
  if (m) {
    let h = m[1];
    if (h.length <= 4) h = [...h].map((c) => c + c).join('');
    if (h.length === 8 && h.endsWith('ff')) h = h.slice(0, 6);
    return `#${h}`;
  }
  m = /^rgba?\(([^)]+)\)$/.exec(s);
  if (m) {
    const parts = m[1].split(/[\s,/]+/).filter(Boolean);
    const hex = parts.slice(0, 3).map((p) => Math.round(p.endsWith('%') ? (parseFloat(p) * 255) / 100 : Number(p)).toString(16).padStart(2, '0'));
    const a = parts[3] === undefined ? 1 : parts[3].endsWith('%') ? parseFloat(parts[3]) / 100 : Number(parts[3]);
    return `#${hex.join('')}${a < 1 ? Math.round(a * 255).toString(16).padStart(2, '0') : ''}`;
  }
  return s.replace(/\s+/g, ' ');
}

export { splitTop, toNumber };
