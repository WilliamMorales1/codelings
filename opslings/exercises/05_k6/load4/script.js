// load4 -- logging in once with setup()
//
// Real APIs want a token. Logging in on every iteration would load-test the
// login endpoint instead of the one you care about, so k6 has a lifecycle:
//
//   setup()            runs once, before any VU starts; its return value...
//   default(data)      ...is passed to every iteration as `data`
//
// The practice API: POST /api/login with the JSON body
//   {"username": "ops", "password": "lings"}
// returns {"token": "..."}; GET /api/me wants the header
//   Authorization: Bearer <token>
// and answers 401 otherwise.
//
// Task: log in once in setup(), then have every iteration GET /api/me
// successfully. k6 does not JSON-encode request bodies for you: an object
// body is sent as an HTML form.
//
//   k6 run -e BASE_URL=http://127.0.0.1:8080 script.js
//   curl -s http://127.0.0.1:8080/__stats | jq      # who got what
//

import http from 'k6/http';
import { check } from 'k6';

const BASE = __ENV.BASE_URL;

export const options = {
  vus: 1,
  iterations: 5,
  thresholds: {
    checks: ['rate==1'],
  },
};

export function setup() {
  const res = http.post(`${BASE}/api/login`, { username: 'ops', password: 'lings' });
  return { token: res.json('token') };
}

export default function (data) {
  const res = http.get(`${BASE}/api/me`, {
    headers: { Authorization: data.token },
  });
  check(res, { 'me is 200': (r) => r.status === 200 });
}
