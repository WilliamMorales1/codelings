import http from 'node:http';
import { afterAll, beforeAll, expect, test } from 'vitest';
import { createServer } from 'vite';
import { exPath } from '../helpers.js';

let backend;
let backendHost;
let vite;
let base;
const seen = [];

beforeAll(async () => {
  backend = http.createServer((req, res) => {
    seen.push({ url: req.url, host: req.headers.host });
    const known = req.headers.host === backendHost && req.url.startsWith('/users');
    res.writeHead(known ? 200 : 404, { 'content-type': 'application/json' });
    res.end(JSON.stringify(known ? [{ name: 'ada' }, { name: 'linus' }] : { error: `no route for ${req.url}` }));
  });
  await new Promise((r) => backend.listen(0, '127.0.0.1', r));
  backendHost = `127.0.0.1:${backend.address().port}`;
  process.env.API_TARGET = `http://${backendHost}`;

  const root = exPath('03_vite', 'vite5');
  vite = await createServer({
    root,
    configFile: `${root}/vite.config.js`,
    logLevel: 'silent',
    server: { port: 0, host: '127.0.0.1', hmr: false, watch: null },
  });
  await vite.listen();
  base = vite.resolvedUrls.local[0].replace(/\/$/, '');
});

afterAll(async () => {
  await vite?.close();
  backend?.closeAllConnections();
  backend?.close();
  delete process.env.API_TARGET;
});

const get = (p) => fetch(base + p, { signal: AbortSignal.timeout(3000) });

test('/api/users reaches the backend as /users', async () => {
  const res = await get('/api/users?limit=2');
  expect(seen.at(-1)?.url).toBe('/users?limit=2');
  expect(res.status).toBe(200);
  expect(await res.json()).toEqual([{ name: 'ada' }, { name: 'linus' }]);
});

test("the backend sees its own Host header", async () => {
  await get('/api/users/1');
  expect(seen.at(-1)?.host).toBe(backendHost);
});

test('non-API paths are still served by vite', async () => {
  const before = seen.length;
  const res = await get('/');
  expect(await res.text()).toContain('<div id="app">');
  expect(seen.length).toBe(before);
});

/* HINT
Use the object form of the proxy entry:
    '/api': {
      target,
      changeOrigin: true,
      rewrite: (p) => p.replace(/^\/api/, ''),
    },
*/
