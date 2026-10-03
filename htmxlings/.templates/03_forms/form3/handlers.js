// form3 - server routes (nothing to change here).
export default function routes() {
  const scores = { 7: 0 };
  return {
    'POST /vote': ({ form }) => {
      if (!(form.id in scores) || !['up', 'down'].includes(form.dir)) {
        return { status: 400, body: 'need id and dir' };
      }
      scores[form.id] += form.dir === 'up' ? 1 : -1;
      return String(scores[form.id]);
    },
  };
}
