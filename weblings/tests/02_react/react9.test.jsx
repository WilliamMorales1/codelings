// @vitest-environment jsdom
import { cleanup, render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { afterEach, expect, test } from 'vitest';
import { Cart, cartReducer, emptyCart } from '@ex/02_react/react9.jsx';

afterEach(cleanup);

const apple = { id: 'a', name: 'apple', price: 0.5 };
const pear = { id: 'p', name: 'pear', price: 0.75 };

function deepFreeze(o) {
  Object.values(o).forEach((v) => typeof v === 'object' && v !== null && deepFreeze(v));
  return Object.freeze(o);
}

test('add puts a new line in the cart', () => {
  expect(cartReducer(deepFreeze({ items: [] }), { type: 'add', product: apple })).toEqual({
    items: [{ ...apple, qty: 1 }],
  });
});

test('add bumps the qty of an existing line without mutating', () => {
  const before = deepFreeze({ items: [{ ...apple, qty: 1 }, { ...pear, qty: 1 }] });
  const after = cartReducer(before, { type: 'add', product: apple });
  expect(after).not.toBe(before);
  expect(after.items).toEqual([{ ...apple, qty: 2 }, { ...pear, qty: 1 }]);
});

test('remove and clear return new state', () => {
  const before = deepFreeze({ items: [{ ...apple, qty: 1 }, { ...pear, qty: 3 }] });
  expect(cartReducer(before, { type: 'remove', id: 'a' }).items).toEqual([{ ...pear, qty: 3 }]);
  expect(cartReducer(before, { type: 'clear' })).toEqual({ items: [] });
});

test('unknown actions throw', () => {
  expect(() => cartReducer(emptyCart, { type: 'checkout' })).toThrow();
});

test('the Cart component re-renders on every dispatch', async () => {
  const user = userEvent.setup();
  render(<Cart products={[apple, pear]} />);
  await user.click(screen.getByRole('button', { name: 'Add apple' }));
  await user.click(screen.getByRole('button', { name: 'Add apple' }));
  await user.click(screen.getByRole('button', { name: 'Add pear' }));
  expect(screen.getAllByRole('listitem').map((li) => li.querySelector("span").textContent)).toEqual(['apple x 2', 'pear x 1']);
  expect(screen.getByText(/^Total:/).textContent).toBe('Total: $1.75');
  await user.click(screen.getByRole('button', { name: 'Remove apple' }));
  expect(screen.getByText(/^Total:/).textContent).toBe('Total: $0.75');
  await user.click(screen.getByRole('button', { name: 'Clear' }));
  expect(screen.queryAllByRole('listitem')).toEqual([]);
});

/* HINT
Return new objects and arrays instead of changing the old ones:
    case 'add': return { ...state, items: exists
        ? state.items.map((i) => i.id === id ? { ...i, qty: i.qty + 1 } : i)
        : [...state.items, { ...action.product, qty: 1 }] };
Add `default: throw new Error(...)`.
In Cart: `const [state, dispatch] = useReducer(cartReducer, emptyCart);`
*/
