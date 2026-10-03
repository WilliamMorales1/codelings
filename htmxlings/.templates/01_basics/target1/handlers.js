// target1 - server routes (nothing to change here).
import { html } from '../../../lib/html.js';

const moons = { mercury: 0, venus: 0, mars: 2 };

export default {
  'GET /details/:planet': ({ params }) => html`<em>${params.planet}: ${moons[params.planet]} moons</em>`,
};
