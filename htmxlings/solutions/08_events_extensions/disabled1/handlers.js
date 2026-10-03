// disabled1 - server routes (nothing to change here).
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

export default function routes() {
  let orders = 0;
  return {
    'POST /order': async ({ form }) => {
      await sleep(300);
      return `<p id="ok">Order #${++orders} placed</p>`;
    },
  };
}
