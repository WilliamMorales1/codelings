// load2 -- options: VUs and duration
//
// Instead of passing --vus / --duration on the command line, a script can
// carry its own settings in an exported `options` object. Durations are
// strings with a unit: '30s', '5m', '1h30m' -- a bare number is read as
// milliseconds. k6 silently ignores keys it does not know, so a setting
// borrowed from another tool just... does nothing.
//
// `k6 inspect script.js` prints the options k6 actually understood.
//
// Task: run 5 VUs for 3 seconds, each VU requesting /api/items and then
// sleeping for 1 second.
//
//   k6 inspect script.js | jq '{vus, duration}'
//   k6 run -e BASE_URL=http://127.0.0.1:8080 script.js
//

import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  users: 5,
  duration: 3,
};

export default function () {
  http.get(`${__ENV.BASE_URL}/api/items`);
  sleep(1);
}
