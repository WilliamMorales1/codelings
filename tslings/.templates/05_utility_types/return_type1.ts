// return_type1 — ReturnType and Parameters
//
// Libraries don't always export the types you need. If you have the
// function, you can get them from it:
//
//   ReturnType<typeof f>      what f returns
//   Parameters<typeof f>      f's parameter types, as a tuple
//   Parameters<typeof f>[0]   the first one
//
// `typeof f` here is the *type-level* typeof: it turns a value into its type.
//
// Task: replace the `any`s with types derived from `createClient` (pretend
// it comes from a package that only exports the function).
//

export function createClient(options: { baseUrl: string; timeoutMs?: number }) {
  return {
    options,
    url(path: string) {
      return new URL(path, options.baseUrl).toString();
    },
  };
}

// TODO: derive these from createClient.
export type Client = any;
export type ClientOptions = any;

export function withTimeout(options: ClientOptions, timeoutMs: number): ClientOptions {
  return { ...options, timeoutMs };
}

export function describe(client: Client): string {
  return `${client.options.baseUrl} (timeout ${client.options.timeoutMs ?? 'none'})`;
}
