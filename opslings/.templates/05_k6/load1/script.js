// load1 -- your first k6 script
//
// k6 (Grafana k6, written in Go) runs load tests written in JavaScript. A
// script exports a default function; every virtual user (VU) calls it in a
// loop, and every HTTP call is measured.
//
// The HTTP module's API is the *default* export of 'k6/http'. Environment
// variables passed with `-e NAME=value` show up in __ENV.
//
// Start the practice API in another terminal and point k6 at it:
//
//   opslings target --port 8080
//   k6 run -e BASE_URL=http://127.0.0.1:8080 --iterations 3 script.js
//
// Task: each iteration makes one GET request to  $BASE_URL/api/items.
// The check runs the target on a random port, so no hard-coded URLs.
//

import { http } from 'k6/http';

export default function () {
  http.get('http://localhost:8080/api/item');
}
