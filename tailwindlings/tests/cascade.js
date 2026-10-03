// A small CSS cascade for jsdom: jsdom's getComputedStyle ignores @media, @layer, @container and var(),
// which is most of what Tailwind v4 emits. This resolves those for a simulated viewport and state.
import postcss from 'postcss';

const REM = 16;

// Properties whose value flows to children when nothing is declared.
const INHERITED = new Set([
  'color', 'font-family', 'font-size', 'font-weight', 'font-style', 'font-variant-numeric', 'line-height',
  'letter-spacing', 'text-align', 'text-transform', 'text-indent', 'white-space', 'word-spacing', 'visibility',
  'cursor', 'list-style-type', 'list-style-position', 'tab-size', 'font-feature-settings', 'font-variation-settings',
  '-webkit-font-smoothing', '-moz-osx-font-smoothing', 'text-wrap', 'overflow-wrap', 'word-break', 'hyphens',
  'direction', 'quotes', 'accent-color', 'caret-color', 'color-scheme', 'text-shadow', 'text-underline-offset',
]);

// ---------- value helpers ----------

/** splitTop splits on `sep` (a single char or /\s/) outside parentheses and quotes. */
export function splitTop(s, sep = ' ') {
  const out = [];
  let depth = 0, cur = '', quote = null;
  for (let i = 0; i < s.length; i++) {
    const ch = s[i];
    if (quote) {
      cur += ch;
      if (ch === quote && s[i - 1] !== '\\') quote = null;
      continue;
    }
    if (ch === '"' || ch === "'") quote = ch;
    if (ch === '(') depth++;
    if (ch === ')') depth--;
    const hit = sep === ' ' ? /\s/.test(ch) : ch === sep;
    if (hit && depth === 0) {
      if (cur.trim() || sep !== ' ') out.push(cur.trim());
      cur = '';
    } else cur += ch;
  }
  if (cur.trim() || (sep !== ' ' && out.length)) out.push(cur.trim());
  return out;
}

/** substitute replaces every var(--x, fallback) in `value`; returns undefined when a var cannot be resolved. */
export function substitute(value, lookup, depth = 0) {
  if (value == null) return undefined;
  if (depth > 32) return undefined;
  let out = '';
  let i = 0;
  while (i < value.length) {
    const at = value.indexOf('var(', i);
    if (at === -1 || (at > 0 && /[\w-]/.test(value[at - 1]))) {
      if (at === -1) {
        out += value.slice(i);
        break;
      }
      out += value.slice(i, at + 4);
      i = at + 4;
      continue;
    }
    out += value.slice(i, at);
    let d = 0, j = at + 3;
    for (; j < value.length; j++) {
      if (value[j] === '(') d++;
      else if (value[j] === ')' && --d === 0) break;
    }
    const inner = value.slice(at + 4, j);
    const comma = splitTop(inner, ',');
    const name = comma[0].trim();
    const fallback = comma.length > 1 ? inner.slice(inner.indexOf(',') + 1) : undefined;
    let v = lookup(name);
    if (v === undefined || v === 'initial') {
      if (fallback === undefined) return undefined;
      v = fallback.trim();
    }
    const r = substitute(v, lookup, depth + 1);
    if (r === undefined) return undefined;
    out += r;
    i = j + 1;
  }
  return out;
}

const UNITS = {
  px: ['px', 1], rem: ['px', REM], em: ['px', REM], pt: ['px', 4 / 3], vw: ['vw', 1], vh: ['vh', 1], '%': ['%', 1],
  s: ['ms', 1000], ms: ['ms', 1], deg: ['deg', 1], turn: ['deg', 360], rad: ['deg', 180 / Math.PI], '': ['', 1],
};

/** toNumber evaluates a length/time/angle, including calc/min/max/clamp, into px, ms or deg. */
export function toNumber(str) {
  if (str == null) return NaN;
  const src = String(str).trim();
  let pos = 0;
  const peek = () => src[pos];
  const ws = () => {
    while (/\s/.test(src[pos] ?? '')) pos++;
  };
  function primary() {
    ws();
    const fn = /^(calc|min|max|clamp)\(/.exec(src.slice(pos));
    if (fn) {
      pos += fn[0].length;
      const args = [expr()];
      ws();
      while (peek() === ',') {
        pos++;
        args.push(expr());
        ws();
      }
      if (peek() !== ')') throw new Error('bad calc');
      pos++;
      if (fn[1] === 'calc') return args[0];
      if (fn[1] === 'min') return Math.min(...args);
      if (fn[1] === 'max') return Math.max(...args);
      return Math.min(Math.max(args[0], args[1]), args[2]);
    }
    if (peek() === '(') {
      pos++;
      const v = expr();
      ws();
      pos++;
      return v;
    }
    const kw = /^(-?)infinity\b/i.exec(src.slice(pos));
    if (kw) {
      pos += kw[0].length;
      return kw[1] ? -Infinity : Infinity;
    }
    const m = /^([+-]?(?:\d+\.?\d*|\.\d+)(?:e[+-]?\d+)?)([a-z%]*)/i.exec(src.slice(pos));
    if (!m) throw new Error(`cannot evaluate ${src}`);
    pos += m[0].length;
    const u = UNITS[m[2].toLowerCase()];
    if (!u) throw new Error(`unknown unit ${m[2]}`);
    return Number(m[1]) * u[1];
  }
  function term() {
    let v = primary();
    for (;;) {
      ws();
      if (peek() === '*') {
        pos++;
        v *= primary();
      } else if (peek() === '/') {
        pos++;
        v /= primary();
      } else return v;
    }
  }
  function expr() {
    let v = term();
    for (;;) {
      ws();
      if ((peek() === '+' || peek() === '-') && /\s/.test(src[pos + 1] ?? '')) {
        const op = src[pos++];
        const r = term();
        v = op === '+' ? v + r : v - r;
      } else return v;
    }
  }
  try {
    const v = expr();
    ws();
    return pos === src.length ? v : NaN;
  } catch {
    return NaN;
  }
}

// ---------- selectors ----------

/** specificity returns [ids, classes, types] for one complex selector. */
export function specificity(sel) {
  let a = 0, b = 0, c = 0;
  let i = 0;
  const ident = () => {
    while (i < sel.length && (/[\w-]/.test(sel[i]) || sel[i] === '\\' || sel.charCodeAt(i) > 127)) i += sel[i] === '\\' ? 2 : 1;
  };
  const argsAt = () => {
    let d = 0, j = i;
    for (; j < sel.length; j++) {
      if (sel[j] === '\\') j++;
      else if (sel[j] === '(') d++;
      else if (sel[j] === ')' && --d === 0) break;
    }
    const inner = sel.slice(i + 1, j);
    i = j + 1;
    return inner;
  };
  const maxOf = (list) =>
    splitTop(list, ',').map(specificity).reduce((m, s) => (cmpSpec(s, m) > 0 ? s : m), [0, 0, 0]);
  while (i < sel.length) {
    const ch = sel[i];
    if (ch === '\\') i += 2;
    else if (ch === '#') {
      i++;
      ident();
      a++;
    } else if (ch === '.') {
      i++;
      ident();
      b++;
    } else if (ch === '[') {
      while (i < sel.length && sel[i] !== ']') i += sel[i] === '\\' ? 2 : 1;
      i++;
      b++;
    } else if (ch === ':') {
      const el = sel[i + 1] === ':';
      i += el ? 2 : 1;
      const start = i;
      ident();
      const name = sel.slice(start, i).toLowerCase();
      const args = sel[i] === '(' ? argsAt() : null;
      if (el || ['before', 'after', 'first-line', 'first-letter'].includes(name)) c++;
      else if (name === 'where') {
        // zero
      } else if (['is', 'not', 'has', 'matches'].includes(name)) {
        const s = maxOf(args ?? '');
        a += s[0];
        b += s[1];
        c += s[2];
      } else b++;
    } else if (/[a-z]/i.test(ch)) {
      ident();
      c++;
    } else i++;
  }
  return [a, b, c];
}

const cmpSpec = (x, y) => x[0] - y[0] || x[1] - y[1] || x[2] - y[2];

// Top-level pseudo-elements style boxes we do not model.
function targetsPseudoElement(sel) {
  let depth = 0;
  for (let i = 0; i < sel.length; i++) {
    const ch = sel[i];
    if (ch === '\\') i++;
    else if (ch === '(') depth++;
    else if (ch === ')') depth--;
    else if (ch === ':' && depth === 0) {
      if (sel[i + 1] === ':') return true;
      if (/^:(before|after|first-line|first-letter)\b/i.test(sel.slice(i))) return true;
    }
  }
  return false;
}

// User-action pseudo-classes become marker classes the test toggles on elements.
const STATE_PSEUDO = [
  [/(?<!\\):hover(?![\w-])/g, '.__tw-hover'],
  [/(?<!\\):focus-visible(?![\w-])/g, '.__tw-focus-visible'],
  [/(?<!\\):focus-within(?![\w-])/g, '.__tw-focus-within'],
  [/(?<!\\):focus(?![\w-])/g, '.__tw-focus'],
  [/(?<!\\):active(?![\w-])/g, '.__tw-active'],
  [/(?<!\\):visited(?![\w-])/g, ':not(*)'],
  [/(?<!\\):(?:host|root)(?![\w-])/g, ':root'],
];

const simulate = (sel) => STATE_PSEUDO.reduce((s, [re, to]) => s.replace(re, to), sel);

// ---------- conditions ----------

function lengthPx(v) {
  const n = toNumber(v);
  return n;
}

function evalFeature(f, env, size) {
  f = f.trim();
  let m = /^\(\s*(min-|max-)?(width|height)\s*:\s*([^)]+)\)$/.exec(f);
  if (m) {
    const have = m[2] === 'width' ? size.width : size.height;
    const want = lengthPx(m[3]);
    if (have == null) return false;
    return m[1] === 'min-' ? have >= want : m[1] === 'max-' ? have <= want : have === want;
  }
  m = /^\(\s*(width|height)\s*(>=|<=|>|<)\s*([^)]+)\)$/.exec(f);
  if (m) {
    const have = m[1] === 'width' ? size.width : size.height;
    const want = lengthPx(m[3]);
    if (have == null) return false;
    return { '>=': have >= want, '<=': have <= want, '>': have > want, '<': have < want }[m[2]];
  }
  m = /^\(\s*([\w-]+)\s*:\s*([^)]+?)\s*\)$/.exec(f);
  if (m) {
    const [, k, v] = m;
    if (k === 'prefers-color-scheme') return v === (env.scheme ?? 'light');
    if (k === 'prefers-reduced-motion') return v === (env.reducedMotion ? 'reduce' : 'no-preference');
    if (k === 'hover' || k === 'any-hover') return v === (env.touch ? 'none' : 'hover');
    if (k === 'pointer' || k === 'any-pointer') return v === (env.touch ? 'coarse' : 'fine');
    if (k === 'orientation') return v === (size.width > (size.height ?? 0) ? 'landscape' : 'portrait');
    if (k === 'forced-colors') return v === (env.forcedColors ? 'active' : 'none');
    if (k === 'prefers-contrast') return v === (env.contrast ?? 'no-preference');
    return false;
  }
  return false;
}

// Evaluates `a and (b)`, `not all and (b)`, comma lists; enough for what Lightning CSS emits.
export function evalQuery(q, env, size) {
  return splitTop(q, ',').some((part) => {
    let neg = false;
    let s = part.trim();
    const nm = /^not\s+(all|screen)\s+and\s+/i.exec(s) ?? /^not\s+/i.exec(s);
    if (nm) {
      neg = true;
      s = s.slice(nm[0].length);
    }
    const bits = s.split(/\s+and\s+/i).map((x) => x.trim()).filter(Boolean);
    const ok = bits.every((b) => {
      if (/^(all|screen)$/i.test(b)) return true;
      if (/^print$/i.test(b)) return false;
      if (/^not\s*\(/i.test(b)) return !evalFeature(b.replace(/^not\s*/i, ''), env, size);
      if (b.startsWith('((')) return evalFeature(b.slice(1, -1), env, size);
      return evalFeature(b, env, size);
    });
    return neg ? !ok : ok;
  });
}

// ---------- shorthands ----------

const SIDES = ['top', 'right', 'bottom', 'left'];
const box = (vals) => {
  const [t, r = t, b = t, l = r] = vals;
  return [t, r, b, l];
};

/** expand turns a declaration into the longhands the cascade tracks. */
export function expand(prop, value) {
  const parts = () => splitTop(value);
  const four = (fmt) => box(parts()).map((v, i) => [fmt(SIDES[i]), v]);
  const two = (fmt, a, b) => {
    const [x, y = x] = parts();
    return [[fmt(a), x], [fmt(b), y]];
  };
  let m;
  if (prop === 'padding' || prop === 'margin') return [[prop, value], ...four((s) => `${prop}-${s}`)];
  if (prop === 'inset') return [[prop, value], ...four((s) => s)];
  if ((m = /^(padding|margin)-(inline|block)$/.exec(prop)))
    return m[2] === 'inline' ? two((s) => `${m[1]}-${s}`, 'left', 'right') : two((s) => `${m[1]}-${s}`, 'top', 'bottom');
  if ((m = /^(padding|margin)-(inline|block)-(start|end)$/.exec(prop)))
    return [[`${m[1]}-${{ 'inline-start': 'left', 'inline-end': 'right', 'block-start': 'top', 'block-end': 'bottom' }[`${m[2]}-${m[3]}`]}`, value]];
  if (prop === 'inset-inline') return two((s) => s, 'left', 'right');
  if (prop === 'inset-block') return two((s) => s, 'top', 'bottom');
  if ((m = /^inset-(inline|block)-(start|end)$/.exec(prop)))
    return [[{ 'inline-start': 'left', 'inline-end': 'right', 'block-start': 'top', 'block-end': 'bottom' }[`${m[1]}-${m[2]}`], value]];
  if ((m = /^border-(width|style|color)$/.exec(prop))) return four((s) => `border-${s}-${m[1]}`);
  if ((m = /^border-(inline|block)-(width|style|color)$/.exec(prop)))
    return m[1] === 'inline'
      ? two((s) => `border-${s}-${m[2]}`, 'left', 'right')
      : two((s) => `border-${s}-${m[2]}`, 'top', 'bottom');
  if ((m = /^border-(inline|block)-(start|end)-(width|style|color)$/.exec(prop)))
    return [[`border-${{ 'inline-start': 'left', 'inline-end': 'right', 'block-start': 'top', 'block-end': 'bottom' }[`${m[1]}-${m[2]}`]}-${m[3]}`, value]];
  if (prop === 'border' || /^border-(top|right|bottom|left)$/.test(prop)) {
    const sides = prop === 'border' ? SIDES : [prop.slice(7)];
    const out = [];
    for (const tok of parts()) {
      const kind = /^(none|hidden|dotted|dashed|solid|double|groove|ridge|inset|outset)$/.test(tok)
        ? 'style'
        : /^([\d.]|thin|medium|thick|calc)/.test(tok) ? 'width' : 'color';
      for (const s of sides) out.push([`border-${s}-${kind}`, tok]);
    }
    return out;
  }
  if (prop === 'border-radius') {
    const [t, r, b, l] = box(parts());
    return [['border-radius', value], ['border-top-left-radius', t], ['border-top-right-radius', r], ['border-bottom-right-radius', b], ['border-bottom-left-radius', l]];
  }
  const logicalRadius = { 'border-start-start-radius': 'border-top-left-radius', 'border-start-end-radius': 'border-top-right-radius', 'border-end-start-radius': 'border-bottom-left-radius', 'border-end-end-radius': 'border-bottom-right-radius' };
  if (logicalRadius[prop]) return [[logicalRadius[prop], value]];
  if (prop === 'gap') {
    const [r, c = r] = parts();
    return [['gap', value], ['row-gap', r], ['column-gap', c]];
  }
  if (prop === 'overflow') {
    const [x, y = x] = parts();
    return [['overflow', value], ['overflow-x', x], ['overflow-y', y]];
  }
  if (prop === 'container') {
    const [name, type = 'normal'] = value.split('/').map((s) => s.trim());
    return [['container-name', name], ['container-type', type]];
  }
  if (prop === 'outline') {
    const out = [];
    for (const tok of parts()) {
      const kind = /^(none|auto|dotted|dashed|solid|double|groove|ridge|inset|outset)$/.test(tok)
        ? 'style'
        : /^([\d.]|thin|medium|thick|calc)/.test(tok) ? 'width' : 'color';
      out.push([`outline-${kind}`, tok]);
    }
    return [['outline', value], ...out];
  }
  return [[prop, value]];
}

// ---------- stylesheet ----------

/** Sheet is a parsed stylesheet that can compute styles for elements of a jsdom document. */
export class Sheet {
  constructor(css) {
    this.rules = [];
    this.properties = new Map();
    this.layerOrder = [];
    const root = postcss.parse(css);
    let order = 0;
    const addLayer = (name) => {
      if (!this.layerOrder.includes(name)) this.layerOrder.push(name);
    };
    const walk = (node, ctx) => {
      for (const child of node.nodes ?? []) {
        if (child.type === 'atrule') {
          const name = child.name.toLowerCase();
          if (name === 'layer') {
            const names = child.params.split(',').map((s) => s.trim()).filter(Boolean);
            const full = names.map((n) => (ctx.layer ? `${ctx.layer}.${n}` : n));
            full.forEach(addLayer);
            if (child.nodes) walk(child, { ...ctx, layer: full[0] ?? `anon${order++}` });
          } else if (name === 'media' || name === 'container' || name === 'supports') {
            walk(child, { ...ctx, conds: [...ctx.conds, { type: name, params: child.params }] });
          } else if (name === 'property') {
            const p = { inherits: true, initial: undefined };
            child.walkDecls((d) => {
              if (d.prop === 'inherits') p.inherits = d.value.trim() === 'true';
              if (d.prop === 'initial-value') p.initial = d.value.trim();
            });
            this.properties.set(child.params.trim(), p);
          } else if (name === 'keyframes' || name === '-webkit-keyframes') {
            (this.keyframes ??= new Map()).set(child.params.trim(), child.toString());
          } else if (name === 'starting-style') {
            // styles before first render; not part of the settled computed style
          } else if (child.nodes) walk(child, ctx);
        } else if (child.type === 'rule') {
          const selectors = splitTop(child.selector.replace(/\s+/g, ' '), ',')
            .filter((s) => !targetsPseudoElement(s))
            .map((s) => ({ raw: s, sim: simulate(s), spec: specificity(s) }));
          const decls = [];
          for (const d of child.nodes ?? []) if (d.type === 'decl') decls.push({ prop: d.prop.startsWith('--') ? d.prop : d.prop.toLowerCase(), value: d.value.replace(/\s+/g, ' ').trim(), important: d.important });
          this.rules.push({ source: child.selector, selectors, decls, conds: ctx.conds, layer: ctx.layer, order: order++ });
        }
      }
    };
    walk(root, { conds: [], layer: null });
  }

  layerRank(layer) {
    return layer == null ? Infinity : this.layerOrder.indexOf(layer);
  }
}

// Marks the element (and its ancestors, as browsers do) with the simulated state classes.
function applyStates(doc, env) {
  const touched = [];
  const mark = (target, cls, withAncestors) => {
    const els = typeof target === 'string' ? [...doc.querySelectorAll(target)] : [].concat(target);
    for (let el of els) {
      do {
        if (!el.classList.contains(cls)) {
          el.classList.add(cls);
          touched.push([el, cls]);
        }
        el = withAncestors ? el.parentElement : null;
      } while (el);
    }
  };
  if (env.hover) mark(env.hover, '__tw-hover', true);
  if (env.active) mark(env.active, '__tw-active', true);
  for (const [key, visible] of [['focus', false], ['focusVisible', true]]) {
    if (!env[key]) continue;
    mark(env[key], '__tw-focus', false);
    if (visible) mark(env[key], '__tw-focus-visible', false);
    const els = typeof env[key] === 'string' ? [...doc.querySelectorAll(env[key])] : [].concat(env[key]);
    mark(els, '__tw-focus-within', true);
  }
  return () => touched.forEach(([el, cls]) => el.classList.remove(cls));
}

/** Styles computes cascaded, var()-resolved values for elements under one environment. */
export class Styles {
  constructor(sheet, doc, env = {}) {
    this.sheet = sheet;
    this.doc = doc;
    this.env = { width: 1280, height: 800, scheme: 'light', ...env };
    this.cache = new Map();
  }

  /** of returns the computed style of `el`. */
  of(el) {
    if (this.cache.has(el)) return this.cache.get(el);
    const undo = applyStates(this.doc, this.env);
    try {
      return this.#compute(el);
    } finally {
      undo();
    }
  }

  #compute(el) {
    if (this.cache.has(el)) return this.cache.get(el);
    const parent = el.parentElement ? this.#compute(el.parentElement) : null;
    const { sheet, env } = this;
    const hits = [];
    for (const rule of sheet.rules) {
      if (!this.#condsHold(rule.conds, el)) continue;
      let best = null;
      for (const s of rule.selectors) {
        let ok = false;
        try {
          ok = el.matches(s.sim);
        } catch {
          ok = false;
        }
        if (ok && (!best || cmpSpec(s.spec, best) > 0)) best = s.spec;
      }
      if (best) hits.push({ rule, spec: best });
    }
    for (const attr of [el.getAttribute('style')].filter(Boolean)) {
      const decls = splitTop(attr, ';').filter(Boolean).map((d) => {
        const i = d.indexOf(':');
        const imp = /!important\s*$/.test(d);
        return { prop: d.slice(0, i).trim().toLowerCase(), value: d.slice(i + 1).replace(/!important\s*$/, '').trim(), important: imp };
      });
      hits.push({ rule: { decls, layer: null, order: Infinity, source: 'style=""' }, spec: [1, 0, 0, 0] });
    }
    const entries = [];
    for (const h of hits) for (const d of h.rule.decls) entries.push({ ...d, spec: h.spec, rule: h.rule });
    const key = (e) => {
      const rank = sheet.layerRank(e.rule.layer);
      // Important declarations reverse layer precedence.
      return [e.important ? 1 : 0, e.important ? -rank : rank, ...e.spec, e.rule.order];
    };
    entries.sort((x, y) => {
      const a = key(x), b = key(y);
      for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return a[i] < b[i] ? -1 : 1;
      return 0;
    });
    const declared = new Map();
    const winners = new Map();
    for (const e of entries)
      for (const [p, v] of expand(e.prop, e.value)) {
        declared.set(p, v);
        winners.set(p, e.rule.source);
      }

    // Custom properties: resolve var() where they are declared, then inherit the result.
    const custom = new Map();
    const lookupCustom = (name, seen = new Set()) => {
      if (custom.has(name)) return custom.get(name);
      let v;
      if (declared.has(name) && !seen.has(name)) {
        seen.add(name);
        const raw = declared.get(name);
        v = raw === 'initial' ? sheet.properties.get(name)?.initial : raw === 'inherit' ? parent?.custom.get(name) : substitute(raw, (n) => lookupCustom(n, seen));
      } else if (!declared.has(name)) {
        const reg = sheet.properties.get(name);
        v = reg && !reg.inherits ? reg.initial : parent?.custom.has(name) ? parent.custom.get(name) : reg?.initial;
      }
      custom.set(name, v);
      return v;
    };
    for (const name of new Set([...declared.keys(), ...(parent?.custom.keys() ?? []), ...sheet.properties.keys()]))
      if (name.startsWith('--')) lookupCustom(name);

    const values = new Map();
    for (const [p, raw] of declared) {
      if (p.startsWith('--')) continue;
      if (raw === 'inherit') values.set(p, parent?.values.get(p));
      else if (raw === 'initial' || raw === 'unset') values.set(p, raw === 'unset' && INHERITED.has(p) ? parent?.values.get(p) : undefined);
      else values.set(p, substitute(raw, (n) => custom.get(n)));
    }
    if (parent) for (const p of INHERITED) if (!declared.has(p) && parent.values.has(p)) values.set(p, parent.values.get(p));

    const computed = new Computed(el, values, custom, winners);
    this.cache.set(el, computed);
    return computed;
  }

  #condsHold(conds, el) {
    for (const c of conds) {
      if (c.type === 'supports') continue;
      if (c.type === 'media') {
        if (!evalQuery(c.params, this.env, { width: this.env.width, height: this.env.height })) return false;
      } else if (c.type === 'container') {
        const m = /^([a-z][\w-]*)?\s*(.*)$/i.exec(c.params.trim());
        let name = m[1];
        let query = m[2];
        if (name && /^(not|and|or)$/i.test(name)) {
          query = c.params;
          name = undefined;
        }
        const box = this.#container(el, name);
        if (!box) return false;
        if (!evalQuery(query, this.env, box)) return false;
      }
    }
    return true;
  }

  // Nearest ancestor that is a size container (optionally with the given name).
  #container(el, name) {
    for (let a = el.parentElement; a; a = a.parentElement) {
      const cs = this.#compute(a);
      const type = cs.get('container-type');
      if (!type || type === 'normal') continue;
      if (name && !(cs.get('container-name') ?? '').split(/\s+/).includes(name)) continue;
      const c = this.env.container;
      const w = typeof c === 'function' ? c(a) : c ?? (a.dataset.width ? Number(a.dataset.width) : undefined);
      return { width: w ?? this.env.width, height: type === 'size' ? this.env.height : null };
    }
    return null;
  }
}

/** Computed is one element's resolved style. */
export class Computed {
  constructor(el, values, custom, winners) {
    this.el = el;
    this.values = values;
    this.custom = custom;
    this.winners = winners;
  }

  /** get returns the resolved value of a property or custom property, or undefined. */
  get(prop) {
    return prop.startsWith('--') ? this.custom.get(prop) : this.values.get(prop);
  }

  /** num evaluates a property to px / ms / deg (NaN when it is not numeric). */
  num(prop) {
    return toNumber(this.get(prop));
  }

  /** from names the selector of the rule that won `prop`, for error messages. */
  from(prop) {
    return this.winners.get(prop);
  }
}
