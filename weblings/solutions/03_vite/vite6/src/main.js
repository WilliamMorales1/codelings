import { version, mode } from 'virtual:build-info';

document.querySelector('#app').textContent = `v${version} (${mode})`;
