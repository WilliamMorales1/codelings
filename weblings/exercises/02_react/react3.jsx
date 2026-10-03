// react3.jsx
//
// Rendering lists: map, filter and keys
//
// Turn an array into elements with `.map()` -- and make sure the callback
// *returns* the element: `todos.map((t) => <li>...</li>)`, not
// `todos.map((t) => { <li>...</li> })`. Every element in a list needs a
// `key` that identifies it among its siblings (a stable id, not the array
// index), so React can tell which item moved, changed or disappeared.
//
// Task: TodoList({ todos, showDone = false }) renders a <ul> with one <li>
// per todo (text = title), keyed by id. Done todos are hidden unless
// showDone is set. When nothing is left to show, render
// <p>Nothing to do</p> instead of an empty list.

export function TodoList({ todos, showDone = false }) {
  return (
    <ul>
      {todos.map((todo) => {
        <li>{todo.title}</li>;
      })}
    </ul>
  );
}
