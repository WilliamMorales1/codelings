// react2.jsx -- reference solution.

export function Badge({ label, tone = 'neutral', count = 0 }) {
  return (
    <span className={`badge badge-${tone}`}>
      {label}
      {count > 0 && <b>{count}</b>}
    </span>
  );
}
