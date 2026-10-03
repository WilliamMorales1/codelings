import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('the bell wiggles', async () => {
  const page = await load('08_polish/animation1');
  expect(page.get('#bell', 'animation'), '#bell animation').toBe('wiggle 1s ease-in-out infinite');
});

test('the wiggle keyframes are in the output', async () => {
  const page = await load('08_polish/animation1');
  expect(page.css).toMatch(/@keyframes wiggle\s*\{/);
});

test('the built-in spinner still spins', async () => {
  const page = await load('08_polish/animation1');
  expect(page.get('#spinner', 'animation')).toBe('spin 1s linear infinite');
});

/* HINT
Wrap the keyframes in @theme and add the variable next to them:
  @theme {
    --animate-wiggle: wiggle 1s ease-in-out infinite;
    @keyframes wiggle { ... }
  }
*/
