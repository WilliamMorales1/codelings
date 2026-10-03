// react3.jsx -- reference solution.

export function TodoList({ todos, showDone = false }) {
  const visible = showDone ? todos : todos.filter((t) => !t.done);
  if (visible.length === 0) return <p>Nothing to do</p>;
  return (
    <ul>
      {visible.map((todo) => (
        <li key={todo.id}>{todo.title}</li>
      ))}
    </ul>
  );
}
