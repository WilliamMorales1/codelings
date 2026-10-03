// react5.jsx
//
// Controlled inputs and form submission
//
// A controlled input takes its value from state and reports every keystroke
// through onChange: `value={title} onChange={(e) => setTitle(e.target.value)}`.
// A `value` without an `onChange` is a read-only input.
//
// Handle submission on the <form> (`onSubmit`), not on the button: that
// catches both the click and the Enter key. Browsers submit forms by
// reloading the page, so call `event.preventDefault()` first.
//
// Task: NewTodoForm({ onAdd })
//   - an input labelled "Title" and a submit button "Add"
//   - submitting calls onAdd with the trimmed title and clears the input
//   - the button is disabled while the trimmed title is empty
//   - no page reload

import { useState } from 'react';

export function NewTodoForm({ onAdd }) {
  const [title, setTitle] = useState('');

  return (
    <form>
      <label htmlFor="title">Title</label>
      <input id="title" value={title} />
      <button onClick={() => onAdd(title)}>Add</button>
    </form>
  );
}
