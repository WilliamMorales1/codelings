// vite2/src/main.js -- reference solution.

const title = import.meta.env.VITE_APP_TITLE;
const api = import.meta.env.VITE_API_URL;

document.title = title;
document.querySelector('#app').innerHTML = `<h1>${title}</h1><p>Talking to ${api}</p>`;
