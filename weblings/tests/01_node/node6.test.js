import { afterAll, beforeAll, expect, test } from 'vitest';
import { createApp } from '@ex/01_node/node6.js';

let server;
let base;

beforeAll(async () => {
  server = createApp();
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  base = `http://127.0.0.1:${server.address().port}`;
});

afterAll(() => {
  server?.closeAllConnections();
  server?.close();
});

// A server that never answers should fail the test, not hang it.
const call = (path, init = {}) => fetch(base + path, { ...init, signal: AbortSignal.timeout(1000) });
const post = (body) => call('/api/todos', { method: 'POST', headers: { 'content-type': 'application/json' }, body });

test('GET /api/todos lists todos as JSON', async () => {
  const res = await call('/api/todos');
  expect(res.status).toBe(200);
  expect(res.headers.get('content-type')).toMatch(/^application\/json/);
  expect(await res.json()).toEqual([{ id: 1, title: 'learn node:http', done: false }]);
});

test('POST /api/todos creates a todo', async () => {
  const res = await post(JSON.stringify({ title: '  write tests  ' }));
  expect(res.status).toBe(201);
  expect(res.headers.get('content-type')).toMatch(/^application\/json/);
  expect(await res.json()).toEqual({ id: 2, title: 'write tests', done: false });
  const all = await (await call('/api/todos')).json();
  expect(all.map((t) => t.title)).toEqual(['learn node:http', 'write tests']);
});

test('?done= filters by status', async () => {
  expect(await (await call('/api/todos?done=true')).json()).toEqual([]);
  expect((await (await call('/api/todos?done=false')).json()).length).toBeGreaterThan(0);
});

test('bad bodies get 400 with an error message', async () => {
  for (const body of ['{"title": ', '{}', '{"title": "   "}']) {
    const res = await post(body);
    expect(res.status, body).toBe(400);
    expect(res.headers.get('content-type')).toMatch(/^application\/json/);
    expect(await res.json()).toHaveProperty('error');
  }
});

test('unknown routes get a JSON 404', async () => {
  const res = await call('/nope');
  expect(res.status).toBe(404);
  expect(await res.json()).toEqual({ error: 'not found' });
});

/* HINT
Parse the URL first: `const url = new URL(req.url, 'http://localhost')`, then
compare `url.pathname` and read `url.searchParams.get('done')`.
A helper keeps responses consistent:
    const send = (status, body) => {
      res.writeHead(status, { 'content-type': 'application/json' });
      res.end(JSON.stringify(body));
    };
Read the body with `for await (const chunk of req) body += chunk;` (make the
handler async), JSON.parse it inside try/catch, and `return` after each send
so the 404 at the bottom only runs when nothing matched.
*/
