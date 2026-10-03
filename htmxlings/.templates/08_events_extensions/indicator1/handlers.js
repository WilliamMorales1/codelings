// indicator1 - server routes (nothing to change here).
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

export default {
  'GET /report': async () => {
    await sleep(400);
    return '<p id="report">All done.</p>';
  },
};
