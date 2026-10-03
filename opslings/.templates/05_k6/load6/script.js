// load6 -- scenarios
//
// One script can model several kinds of users at once. Each entry in
// options.scenarios picks an *executor* (how iterations are scheduled) and
// the exported function it runs (`exec`; the default export otherwise):
//
//   constant-vus        N VUs looping for a duration
//   shared-iterations   a fixed number of iterations shared by N VUs
//   per-vu-iterations   each of N VUs runs M iterations
//   constant-arrival-rate / ramping-arrival-rate   open model: requests/s
//
// Task:
//   browse    constant-vus, 3 VUs for 3s, runs browse()
//   checkout  shared-iterations, 2 VUs sharing 10 iterations, runs checkout()
//
//   k6 inspect script.js | jq .scenarios
//   k6 run -e BASE_URL=http://127.0.0.1:8080 script.js
//

import http from 'k6/http';
import { sleep } from 'k6';

const BASE = __ENV.BASE_URL;

export const options = {
  scenarios: {
    browse: {
      executor: 'constant-vu',
      vus: 3,
      duration: '3s',
    },
    checkout: {
      executor: 'shared-iterations',
      vus: 2,
      iterations: 10,
    },
  },
};

export function browse() {
  http.get(`${BASE}/api/items`);
  sleep(0.5);
}

export function checkout() {
  const id = Math.floor(Math.random() * 5) + 1;
  http.get(`${BASE}/api/items/${id}`);
}
