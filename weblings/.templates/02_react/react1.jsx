// react1.jsx
//
// JSX is not HTML
//
// JSX looks like HTML but compiles to JavaScript function calls, so a few
// things differ:
//   - attributes are DOM property names: `className`, `htmlFor`
//   - every tag must be closed: `<img />`, `<br />`
//   - `style` takes an object: `style={{ color: 'gray' }}`
//   - a component returns ONE expression; wrap siblings in a fragment `<>...</>`
//
// Task: make ProfileCard compile and render, without adding a wrapper
// element -- the five elements should be direct children of whatever the
// card is rendered into.

export function ProfileCard({ user }) {
  return (
    <h2 class="title">{user.name}</h2>
    <img src={user.avatar} alt={`${user.name}'s avatar`}>
    <label for="bio">Bio</label>
    <textarea id="bio" defaultValue={user.bio}></textarea>
    <p style="color: gray">Joined {user.joined}</p>
  );
}
