// A tiny zero-dependency server for one exercise: static pages from its directory plus the routes in handlers.js.
import fs from 'node:fs';
import http from 'node:http';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const ROOT = path.resolve(import.meta.dirname, '..');
const ASSETS = {
  '/htmx.js': path.join(ROOT, 'node_modules/htmx.org/dist/htmx.js'),
  '/ext/json-enc.js': path.join(ROOT, 'node_modules/htmx-ext-json-enc/dist/json-enc.js'),
  '/style.css': path.join(ROOT, 'lib/style.css'),
};
const TYPES = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.css': 'text/css' };

/** compile turns 'GET /contacts/:id' into a matcher returning params or null. */
function compile(key) {
  const [method, pattern] = key.trim().split(/\s+/);
  const names = [];
  const re = new RegExp(
    '^' + pattern.replace(/[.*+?^${}()|[\]\\]/g, '\\$&').replace(/:(\w+)/g, (_, n) => (names.push(n), '([^/]+)')) + '$',
  );
  return (m, p) => {
    if (m !== method.toUpperCase()) return null;
    const hit = p.match(re);
    return hit && Object.fromEntries(names.map((n, i) => [n, decodeURIComponent(hit[i + 1])]));
  };
}

/** loadRoutes imports an exercise's handlers.js (fresh each call) and returns its route table. */
export async function loadRoutes(dir) {
  const file = path.join(dir, 'handlers.js');
  if (!fs.existsSync(file)) return [];
  const url = pathToFileURL(file).href + `?v=${fs.statSync(file).mtimeMs}-${Math.random()}`;
  const mod = await import(url);
  const table = typeof mod.default === 'function' ? mod.default() : mod.default ?? {};
  return Object.entries(table).map(([key, fn]) => ({ key, match: compile(key), fn }));
}

// Repeated keys (checkboxes, multi-selects) become arrays; everything else stays a string.
function toObject(params) {
  const out = {};
  for (const [k, v] of params) {
    if (!(k in out)) out[k] = v;
    else out[k] = [].concat(out[k], v);
  }
  return out;
}

function parseBody(raw, type = '') {
  if (!raw) return {};
  if (type.includes('application/json')) {
    try {
      return JSON.parse(raw);
    } catch {
      return {};
    }
  }
  return toObject(new URLSearchParams(raw));
}

function readBody(req) {
  return new Promise((resolve) => {
    let s = '';
    req.setEncoding('utf8');
    req.on('data', (c) => (s += c));
    req.on('end', () => resolve(s));
  });
}

function sendFile(res, file) {
  res.writeHead(200, { 'content-type': TYPES[path.extname(file)] ?? 'application/octet-stream' });
  res.end(fs.readFileSync(file));
}

/** staticFile maps / to index.html and /about to about.html inside the exercise directory. */
function staticFile(dir, p) {
  if (ASSETS[p]) return ASSETS[p];
  const name = p === '/' ? 'index.html' : p.slice(1);
  if (name.includes('..') || name.includes('/')) return null;
  for (const cand of [name, name + '.html']) {
    const f = path.join(dir, cand);
    if (cand !== 'handlers.js' && fs.existsSync(f) && fs.statSync(f).isFile()) return f;
  }
  return null;
}

/**
 * createServer serves one exercise directory.
 * `reload` re-imports handlers.js whenever it changes (used by `npm run serve`); tests load it once so
 * handler state lives for the whole test. `onRequest` sees every request htmx makes.
 */
export async function createServer(dir, { reload = false, onRequest } = {}) {
  let routes = await loadRoutes(dir);
  let stamp = () => {
    try {
      return fs.statSync(path.join(dir, 'handlers.js')).mtimeMs;
    } catch {
      return 0;
    }
  };
  let seen = stamp();

  const server = http.createServer(async (req, res) => {
    const url = new URL(req.url, 'http://x');
    const raw = await readBody(req);
    const info = {
      method: req.method,
      path: url.pathname,
      url: req.url,
      query: toObject(url.searchParams),
      form: parseBody(raw, req.headers['content-type']),
      body: raw,
      headers: req.headers,
      params: {},
    };
    onRequest?.(info);
    try {
      if (reload && stamp() !== seen) {
        seen = stamp();
        routes = await loadRoutes(dir);
      }
      for (const r of routes) {
        const params = r.match(req.method, url.pathname);
        if (!params) continue;
        let out = await r.fn({ ...info, params });
        if (out == null) out = '';
        if (typeof out === 'string' || out[Symbol.for('htmxlings.html')]) out = { body: out };
        const headers = { 'content-type': 'text/html; charset=utf-8', ...(out.headers ?? {}) };
        res.writeHead(out.status ?? 200, headers);
        res.end(String(out.body ?? ''));
        return;
      }
      const file = req.method === 'GET' && staticFile(dir, url.pathname);
      if (file) return sendFile(res, file);
      res.writeHead(404, { 'content-type': 'text/plain' });
      res.end(`no route for ${req.method} ${url.pathname}`);
    } catch (e) {
      console.error(e);
      res.writeHead(500, { 'content-type': 'text/plain' });
      res.end(String(e?.stack ?? e));
    }
  });

  return {
    server,
    listen(port = 0, host = '127.0.0.1') {
      return new Promise((resolve, reject) => {
        server.once('error', reject);
        server.listen(port, host, () => {
          server.off('error', reject);
          resolve(`http://${host}:${server.address().port}`);
        });
      });
    },
    close: () => new Promise((resolve) => {
      server.close(() => resolve());
      server.closeAllConnections();
    }),
  };
}
