// abstract1 — Abstract classes
//
// An abstract class can't be instantiated; it exists to be extended. An
// `abstract` method has no body, and every concrete subclass *must*
// implement it — forgetting is a compile error, not a silent default.
//
// Here the base class supplies a dummy `area()` returning 0, and Triangle's
// author spelled the override `getArea`. Nobody noticed: every triangle has
// area 0.
//
// Task: make Shape abstract with an abstract `area(): number`, then fix the
// subclass the compiler complains about. (The course tsconfig has
// `noImplicitOverride`: overriding a *concrete* method needs the `override`
// keyword, which also catches typos like this one.)
//

export class Shape {
  area(): number {
    return 0;
  }

  describe(): string {
    return `${this.constructor.name} with area ${this.area().toFixed(1)}`;
  }
}

export class Square extends Shape {
  side: number;
  constructor(side: number) {
    super();
    this.side = side;
  }
  override area(): number {
    return this.side ** 2;
  }
}

export class Triangle extends Shape {
  base: number;
  height: number;
  constructor(base: number, height: number) {
    super();
    this.base = base;
    this.height = height;
  }
  getArea(): number {
    return (this.base * this.height) / 2;
  }
}
