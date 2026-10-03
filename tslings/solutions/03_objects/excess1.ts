// excess1 — Excess property checks
//
// TypeScript's object types are *structural* and open: an object with extra
// properties is still assignable to a type that doesn't mention them. There
// is one exception: an object *literal* written directly where a type is
// expected gets an "excess property check", which is how typos get caught.
//
// Put the literal in a variable first and the check is gone — the typo just
// becomes an extra property nobody reads.
//
// Task: make both servers start as intended: dev on localhost:3000 with
// verbose logging, prod on example.com:443. Fix the second one in a way that
// would have caught its typo.

export interface ServerOptions {
  port: number;
  host?: string;
  verbose?: boolean;
}

export function start(opts: ServerOptions): string {
  return `${opts.host ?? 'localhost'}:${opts.port}${opts.verbose ? ' (verbose)' : ''}`;
}

export const dev = start({ port: 3000, verbose: true });

const prodOptions: ServerOptions = { port: 443, host: 'example.com' };
export const prod = start(prodOptions);
