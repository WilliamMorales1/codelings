// classes1 — Class fields
//
// In JavaScript you can invent properties in the constructor
// (`this.balance = 0`). TypeScript wants every field declared in the class
// body, with its type:
//
//   class Account {
//     owner: string;
//     balance = 0;             // type inferred from the initialiser
//     constructor(owner: string) { this.owner = owner; }
//   }
//
// (You may meet the shorthand `constructor(public owner: string)` — a
// "parameter property". It generates code, so Node's type stripping and
// `erasableSyntaxOnly` reject it, like enums. Plain fields are the portable
// choice.)
//
// Task: declare the fields, and make `withdraw` refuse to overdraw by
// throwing an Error('insufficient funds').
//

export class Account {
  constructor(owner: string, balance: number) {
    this.owner = owner;
    this.balance = balance;
  }

  deposit(amount: number): void {
    this.balance += amount;
  }

  withdraw(amount: number): void {
    this.balance -= amount;
  }
}
