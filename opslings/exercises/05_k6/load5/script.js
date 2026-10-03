// load5 -- ramping stages
//
// Real traffic does not jump from 0 to 100 users. `stages` ramps the number
// of VUs linearly towards each `target` over each `duration`:
//
//   stages: [
//     { duration: '30s', target: 20 },   // ramp up to 20 VUs
//     { duration: '1m',  target: 20 },   // hold
//     { duration: '10s', target: 0 },    // ramp down
//   ]
//
// Percentile thresholds are written p(N): 'p(95)<300', 'p(99.9)<1000'.
//
// Task (short, it's a laptop):
//   - ramp 0 -> 5 VUs over 1s, hold 5 VUs for 2s, ramp down to 0 over 1s
//   - fail the run when the 95th percentile of http_req_duration is 300ms
//     or more
// The endpoint answers after SLOW_MS milliseconds (50 by default), so
//   k6 run -e BASE_URL=http://127.0.0.1:8080 script.js                  passes
//   k6 run -e BASE_URL=http://127.0.0.1:8080 -e SLOW_MS=400 script.js   fails
//

import http from 'k6/http';
import { sleep } from 'k6';

const BASE = __ENV.BASE_URL;
const SLOW_MS = __ENV.SLOW_MS || 50;

export const options = {
  stages: [
    { duration: '1s', vus: 5 },
    { duration: '2s', vus: 5 },
  ],
  thresholds: {
    http_req_duration: ['p95 < 300ms'],
  },
};

export default function () {
  http.get(`${BASE}/slow?ms=${SLOW_MS}`);
  sleep(0.2);
}
