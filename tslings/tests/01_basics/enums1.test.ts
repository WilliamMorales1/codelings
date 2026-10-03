import { stripTypeScriptTypes } from 'node:module';
import { expect, expectTypeOf, it } from 'vitest';
import { LogLevel, shouldLog } from '@ex/01_basics/enums1.ts';
import { exerciseSource } from '../helpers.ts';

it('uses readable string values', () => {
  expect(LogLevel.Warn).toBe('warn');
  expect(Object.values(LogLevel)).toEqual(['debug', 'info', 'warn', 'error']);
});

it('compares levels', () => {
  expect(shouldLog(LogLevel.Error, LogLevel.Warn)).toBe(true);
  expect(shouldLog('debug', 'info')).toBe(false);
});

it('LogLevel is a union of strings', () => {
  expectTypeOf<LogLevel>().toEqualTypeOf<'debug' | 'info' | 'warn' | 'error'>();
  // @ts-expect-error not a level
  shouldLog('verbose', 'info');
});

it('is erasable syntax that Node can run directly', () => {
  expect(() => stripTypeScriptTypes(exerciseSource('01_basics/enums1.ts'))).not.toThrow();
});

/* HINT
  export const LogLevel = { Debug: 'debug', Info: 'info', ... } as const;
  export type LogLevel = (typeof LogLevel)[keyof typeof LogLevel];
Read the type right to left: `keyof typeof LogLevel` is 'Debug' | 'Info' | ...,
and indexing the object's type with that union gives the union of its values.
A const and a type can share one name, just like the enum did.
*/
