// events1 - server routes (nothing to change here).
export default {
  'GET /secret': ({ query }) =>
    query.token === 'abc123' ? 'Balance: 42 EUR' : { status: 200, body: 'Not logged in' },
};
