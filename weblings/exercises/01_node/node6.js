// node6.js
//
// A JSON API with node:http
//
// `http.createServer((req, res) => ...)` is all Node gives you: no router, no
// body parser. `req` is a readable stream (collect the body with
// `for await (const chunk of req)`), `req.url` is the path *plus* the query
// string, and `res.end()` only accepts strings or Buffers. Every request must
// be answered, or the client waits forever.
//
// Task: a tiny in-memory todo API.
//   GET  /api/todos            200, JSON array of all todos
//   GET  /api/todos?done=true  200, only todos whose `done` matches
//   POST /api/todos            body {"title": "..."}; 201 with the new todo
//                              {id, title, done: false}; 400 {"error": ...}
//                              for invalid JSON or a missing/blank title
//   anything else              404 {"error": "not found"}
// Every response has `content-type: application/json`.

import http from 'node:http';

export function createApp() {
  const todos = [{ id: 1, title: 'learn node:http', done: false }];
  let nextId = 2;

  return http.createServer((req, res) => {
    if (req.method === 'GET' && req.url === '/api/todos') {
      res.end(todos);
    }
    if (req.method === 'POST' && req.url === '/api/todos') {
      const todo = { id: nextId++, title: req.body.title, done: false };
      todos.push(todo);
      res.statusCode = 201;
      res.end(JSON.stringify(todo));
    }
  });
}
