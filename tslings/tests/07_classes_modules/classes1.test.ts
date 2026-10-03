import { stripTypeScriptTypes } from 'node:module';
import { expect, expectTypeOf, it } from 'vitest';
import { Account } from '@ex/07_classes_modules/classes1.ts';
import { exerciseSource } from '../helpers.ts';

it('moves money', () => {
  const a = new Account('Ada', 100);
  a.deposit(50);
  a.withdraw(30);
  expect(a.balance).toBe(120);
  expect(a.owner).toBe('Ada');
});

it('refuses to overdraw', () => {
  const a = new Account('Ada', 10);
  expect(() => a.withdraw(11)).toThrow('insufficient funds');
  expect(a.balance).toBe(10);
});

it('declares typed fields', () => {
  expectTypeOf<Account['balance']>().toEqualTypeOf<number>();
  expectTypeOf<Account['owner']>().toEqualTypeOf<string>();
});

it('stays erasable (no parameter properties)', () => {
  expect(() => stripTypeScriptTypes(exerciseSource('07_classes_modules/classes1.ts'))).not.toThrow();
});

/* HINT
Add `owner: string;` and `balance: number;` at the top of the class body.
In withdraw, check before subtracting:
  if (amount > this.balance) throw new Error('insufficient funds');
*/
