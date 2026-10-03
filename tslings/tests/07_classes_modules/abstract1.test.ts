import { expect, it } from 'vitest';
import { Shape, Square, Triangle } from '@ex/07_classes_modules/abstract1.ts';

it('computes areas', () => {
  expect(new Square(3).area()).toBe(9);
  expect(new Triangle(4, 5).area()).toBe(10);
  expect(new Triangle(4, 5).describe()).toBe('Triangle with area 10.0');
});

it('cannot instantiate the base class', () => {
  const make = () => {
    // @ts-expect-error Shape is abstract
    return new Shape();
  };
  expect(typeof make).toBe('function');
});

/* HINT
  export abstract class Shape {
    abstract area(): number;
    ...
  }
Then the compiler says Triangle does not implement `area`. Rename getArea.
(Implementing an abstract method doesn't need `override`, but it's allowed.)
*/
