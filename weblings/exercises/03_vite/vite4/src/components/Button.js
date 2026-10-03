export function Button(label) {
  const el = document.createElement('button');
  el.className = 'btn-aliased';
  el.textContent = label;
  return el;
}
