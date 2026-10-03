// react2.jsx
//
// Props and default values
//
// A component is called with ONE argument: an object holding every prop.
// Destructure it in the parameter list, and give optional props defaults
// right there: `function Badge({ label, tone = 'neutral' })`.
//
// Watch out for `{count && <b>{count}</b>}`: when count is 0, `0 && ...` is
// 0, and React renders the number 0. Make conditions real booleans.
//
// Task: <Badge label="Inbox" tone="info" count={3} /> renders
//     <span class="badge badge-info">Inbox<b>3</b></span>
// `tone` defaults to "neutral"; the <b> appears only when count > 0.

export function Badge(label, tone, count) {
  return (
    <span className={'badge badge-' + tone}>
      {label}
      {count && <b>{count}</b>}
    </span>
  );
}
