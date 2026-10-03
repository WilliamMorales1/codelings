// hxheaders1 - server routes (nothing to change here).
const guard = (headers, ok) =>
  headers['x-csrf-token'] === 's3cr3t' ? ok : { status: 403, body: 'bad CSRF token' };

export default {
  'POST /save': ({ headers }) => guard(headers, 'saved'),
  'POST /reset': ({ headers }) => guard(headers, 'reset'),
};
