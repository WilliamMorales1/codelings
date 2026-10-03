// vite2/src/main.js
//
// Environment variables in Vite
//
// Vite loads `.env` files from the project root, but only variables whose
// names start with `VITE_` reach browser code, as `import.meta.env.VITE_*`.
// Everything else stays on the build machine -- which is the point: the
// bundle is public, so a secret in it is a published secret. `process.env`
// does not exist in the browser at all.
//
// Task: make the API URL and the app title available to this file, and keep
// DB_PASSWORD out of the bundle. You will need to edit ../.env too (keep the
// DB_PASSWORD line there; the server side still needs it).
// Check the result: `npx vite build exercises/03_vite/vite2 --outDir /tmp/vite2`
// and grep the JS in /tmp/vite2/assets.

const title = import.meta.env.APP_TITLE;
const api = process.env.API_URL;

document.title = title;
document.querySelector('#app').innerHTML = `<h1>${title}</h1><p>Talking to ${api}</p>`;
