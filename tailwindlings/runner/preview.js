import fs from 'node:fs';
import http from 'node:http';
import path from 'node:path';
import { listFiles, stamp } from './exercises.js';
import { buildCss, sourcesOf } from './tailwind.js';
import { paint, say } from './ui.js';

const CSS_URL = '/__tailwindlings.css';
const STAMP_URL = '/__tailwindlings.stamp';

// Polls the exercise's file stamp and reloads when a save lands.
const RELOAD = `<script>
(() => {
  let last = null;
  setInterval(async () => {
    try {
      const s = await (await fetch('${STAMP_URL}', { cache: 'no-store' })).text();
      if (last !== null && s !== last) location.reload();
      last = s;
    } catch {}
  }, 700);
})();
</script>`;

const TYPES = { '.html': 'text/html', '.css': 'text/css', '.js': 'text/javascript', '.svg': 'image/svg+xml', '.png': 'image/png', '.jpg': 'image/jpeg', '.webp': 'image/webp' };

function inject(html) {
  const link = `<link rel="stylesheet" href="${CSS_URL}">`;
  html = /<\/head>/i.test(html) ? html.replace(/<\/head>/i, `${link}\n</head>`) : `${link}\n${html}`;
  return /<\/body>/i.test(html) ? html.replace(/<\/body>/i, `${RELOAD}\n</body>`) : html + RELOAD;
}

/** preview serves one exercise with freshly compiled CSS on every request. */
export function preview(ex, { port = 0 } = {}) {
  const { html, base } = sourcesOf(ex.path);
  const allowed = new Set(listFiles(ex.isDir ? ex.path : html).map((f) => path.resolve(f)));
  const server = http.createServer(async (req, res) => {
    const url = new URL(req.url, 'http://x');
    try {
      if (url.pathname === STAMP_URL) {
        res.writeHead(200, { 'content-type': 'text/plain' }).end(stamp(ex));
      } else if (url.pathname === CSS_URL) {
        const { css } = await buildCss(ex.path);
        res.writeHead(200, { 'content-type': 'text/css', 'cache-control': 'no-store' }).end(css);
      } else if (url.pathname === '/' || url.pathname === '/index.html') {
        res.writeHead(200, { 'content-type': 'text/html; charset=utf-8', 'cache-control': 'no-store' }).end(inject(fs.readFileSync(html, 'utf8')));
      } else {
        const file = path.resolve(base, '.' + decodeURIComponent(url.pathname));
        if (!allowed.has(file)) return res.writeHead(404).end('not found');
        res.writeHead(200, { 'content-type': TYPES[path.extname(file)] ?? 'application/octet-stream' }).end(fs.readFileSync(file));
      }
    } catch (e) {
      // A syntax error in style.css should show up in the browser, not kill the server.
      const body = `/* tailwindlings: build failed */\nbody::before { content: ${JSON.stringify(String(e.message).split('\n')[0])}; display: block; padding: 1rem; background: #fee; color: #900; font: 14px monospace; }`;
      res.writeHead(url.pathname === CSS_URL ? 200 : 500, { 'content-type': url.pathname === CSS_URL ? 'text/css' : 'text/plain' }).end(url.pathname === CSS_URL ? body : String(e.message));
    }
  });
  return new Promise((resolve) => {
    server.listen(port, '127.0.0.1', () => {
      const { port: p } = server.address();
      say('bold', `previewing ${ex.id}`);
      console.log(`  ${paint('cyan', `http://127.0.0.1:${p}/`)}`);
      say('dim', '  the page reloads when you save; Ctrl-C to stop');
      resolve(server);
    });
  });
}
