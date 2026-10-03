// react9.jsx -- reference solution.

import { useReducer } from 'react';

export const emptyCart = { items: [] };

export function cartReducer(state, action) {
  switch (action.type) {
    case 'add': {
      const exists = state.items.some((i) => i.id === action.product.id);
      return {
        ...state,
        items: exists
          ? state.items.map((i) => (i.id === action.product.id ? { ...i, qty: i.qty + 1 } : i))
          : [...state.items, { ...action.product, qty: 1 }],
      };
    }
    case 'remove':
      return { ...state, items: state.items.filter((i) => i.id !== action.id) };
    case 'clear':
      return { ...state, items: [] };
    default:
      throw new Error(`unknown action: ${action.type}`);
  }
}

export function Cart({ products }) {
  const [state, dispatch] = useReducer(cartReducer, emptyCart);
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
