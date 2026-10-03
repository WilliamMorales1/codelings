// react5.jsx -- reference solution.

import { useState } from 'react';

export function NewTodoForm({ onAdd }) {
  const [title, setTitle] = useState('');
  const trimmed = title.trim();

  function handleSubmit(event) {
    event.preventDefault();
    if (!trimmed) return;
    onAdd(trimmed);
    setTitle('');
  }

  return (
    <form onSubmit={handleSubmit}>
      <label htmlFor="title">Title</label>
      <input id="title" value={title} onChange={(e) => setTitle(e.target.value)} />
      <button type="submit" disabled={!trimmed}>
        Add
      </button>
    </form>
  );
}
