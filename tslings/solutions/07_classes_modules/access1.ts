// access1 — private versus #private
//
// TypeScript's `private` keyword is a compile-time rule only. At runtime the
// field is an ordinary property: JSON.stringify prints it, Object.keys lists
// it, and `(session as any).token` reads it.
//
// JavaScript's own `#field` syntax is enforced by the engine: the field
// doesn't exist outside the class body at all.
//
// This session object ends up in log lines via JSON.stringify — and so does
// its token.
//
// Task: make the token truly private so it never appears in serialised
// output. Keep `authHeader()` working.

export class Session {
  readonly user: string;
  #token: string;

  constructor(user: string, token: string) {
    this.user = user;
    this.#token = token;
  }

  authHeader(): string {
    return `Bearer ${this.#token}`;
  }
}
