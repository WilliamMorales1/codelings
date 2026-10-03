// react9.jsx
//
// useReducer and immutable updates
//
// When state has several related parts and several ways to change, move the
// logic into a reducer: a pure function `(state, action) => newState`.
// "Pure" means it never modifies `state`; it returns a new object instead.
// React compares old and new state by reference, so a reducer that mutates
// and returns the same object makes React skip the re-render entirely.
//
// Task: fix cartReducer and wire it into Cart with useReducer.
//   { type: 'add', product }   adds the product with qty 1, or bumps its qty
//   { type: 'remove', id }     removes that line
//   { type: 'clear' }          empties the cart
//   any other type             throws an Error
// The state shape is { items: [{ id, name, price, qty }] }.

import { useReducer } from 'react';

export const emptyCart = { items: [] };

export function cartReducer(state, action) {
  switch (action.type) {
    case 'add': {
      const line = state.items.find((i) => i.id === action.product.id);
      if (line) line.qty += 1;
      else state.items.push({ ...action.product, qty: 1 });
      return state;
    }
    case 'remove':
      state.items = state.items.filter((i) => i.id !== action.id);
      return state;
    case 'clear':
      state.items = [];
      return state;
  }
}

export function Cart({ products }) {
  const state = emptyCart;
  const dispatch = (action) => cartReducer(state, action);
  const total = state.items.reduce((sum, i) => sum + i.price * i.qty, 0);

  return (
    <div>
      {products.map((p) => (
        <button key={p.id} onClick={() => dispatch({ type: 'add', product: p })}>
          Add {p.name}
        </button>
      ))}
      <ul>
        {state.items.map((i) => (
          <li key={i.id}>
            <span>
              {i.name} x {i.qty}
            </span>{' '}
            <button onClick={() => dispatch({ type: 'remove', id: i.id })}>Remove {i.name}</button>
          </li>
        ))}
      </ul>
      <p>Total: ${total.toFixed(2)}</p>
      <button onClick={() => dispatch({ type: 'clear' })}>Clear</button>
    </div>
  );
}
