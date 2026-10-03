// load3 -- checks and thresholds
//
// check()      asserts something about a response. A failed check is
//              counted in the `checks` metric but does not stop the test.
// thresholds   pass/fail criteria for the whole run. When one is crossed,
//              k6 exits with code 99 -- that is what fails your CI job.
//
//   thresholds: {
//     metric_name: ['aggregation<value', ...],
//   }
//   e.g.  http_req_duration: ['p(95)<200'],  checks: ['rate>0.99']
//
// This smoke test is reused for several endpoints via TARGET_PATH. Task:
//   - check that every response has status 200
//   - thresholds: fewer than 1% failed requests (http_req_failed),
//     95th percentile of http_req_duration under 200ms,
//     and more than 99% of checks passing
// Then the healthy endpoint passes and the flaky one fails the run:
//
//   k6 run -e BASE_URL=http://127.0.0.1:8080 script.js; echo $status
//   k6 run -e BASE_URL=http://127.0.0.1:8080 -e TARGET_PATH=/flaky script.js; echo $status
//

import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE = __ENV.BASE_URL;
const PATH = __ENV.TARGET_PATH || '/api/items';

export const options = {
  vus: 2,
  duration: '2s',
  thresholds: {
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<200'],
    checks: ['rate>0.99'],
  },
};

export default function () {
  const res = http.get(`${BASE}${PATH}`);
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(0.1);
}
