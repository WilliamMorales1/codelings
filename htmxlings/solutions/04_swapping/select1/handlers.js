// select1 - a "legacy" endpoint we are not allowed to change.
import { html } from '../../../lib/html.js';

export default {
  'GET /weather': () => html`<!doctype html>
<html>
<head><title>Weather Corp</title></head>
<body>
  <header><h1>Weather Corp</h1><nav><a href="/">Home</a> <a href="/radar">Radar</a></nav></header>
  <main>
    <div id="forecast"><p>Sunny, 24&deg;C</p><p>Tomorrow: rain</p></div>
    <footer>Copyright Weather Corp</footer>
  </main>
</body>
</html>`,
};
