// deleterow - server routes. TASK: make the delete response swappable.
export default function routes() {
  const contacts = new Map([['1', 'Ada'], ['2', 'Grace'], ['3', 'Katherine']]);
  return {
    'GET /contacts': () => [...contacts.values()].join(', '),
    'DELETE /contacts/:id': ({ params }) => {
      contacts.delete(params.id);
      return { status: 204 };
    },
  };
}
