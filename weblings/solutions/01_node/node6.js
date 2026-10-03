// node6.js -- reference solution.

import http from 'node:http';

export function createApp() {
  const todos = [{ id: 1, title: 'learn node:http', done: false }];
  let nextId = 2;

  return http.createServer(async (req, res) => {
    const send = (status, body) => {
      res.writeHead(status, { 'content-type': 'application/json' });
      res.end(JSON.stringify(body));
    };
    const url = new URL(req.url, 'http://localhost');

    if (req.method === 'GET' && url.pathname === '/api/todos') {
      const done = url.searchParams.get('done');
      return send(200, done === null ? todos : todos.filter((t) => String(t.done) === done));
    }

    if (req.method === 'POST' && url.pathname === '/api/todos') {
      let body = '';
      for await (const chunk of req) body += chunk;
      let data;
      try {
        data = JSON.parse(body);
      } catch {
        return send(400, { error: 'invalid JSON' });
      }
      if (typeof data?.title !== 'string' || !data.title.trim()) {
        return send(400, { error: 'title is required' });
      }
      const todo = { id: nextId++, title: data.title.trim(), done: false };
      todos.push(todo);
      return send(201, todo);
    }

    send(404, { error: 'not found' });
  });
}
