// Status comes from the server as "ok" | "warn" | "down".
const hue = { ok: 'green', warn: 'amber', down: 'red' };

export function badgeClasses(status) {
  const c = hue[status];
  return ['rounded-full', 'px-2', `bg-${c}-100`, `text-${c}-800`];
}

if (typeof document !== 'undefined') {
  for (const el of document.querySelectorAll('[data-status]')) {
    el.classList.add(...badgeClasses(el.dataset.status));
  }
}
