const res = await fetch('/api/users');
const users = await res.json();
document.querySelector('#app').textContent = users.map((u) => u.name).join(', ');
