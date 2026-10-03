// merging1 — Declaration merging and module augmentation
//
// This exercise is a directory: host.ts (a tiny plugin host, think of it as
// a library you don't own) and analytics.ts (your plugin).
//
// Two `interface` declarations with the same name in the same scope *merge*
// into one. From another file you can add to a module's interface with a
// module augmentation:
//
//   declare module './host.ts' {
//     interface Plugins {
//       myPlugin: MyPlugin;
//     }
//   }
//
// Libraries use this so that users can register things the library can't
// know about: Express's Request, Vue's ComponentCustomProperties, Pinia
// stores, i18next resources.
//
// Task: in analytics.ts, augment `Plugins` so that
// `usePlugin('analytics')` is typed as Analytics everywhere. Don't edit this
// file.

// Plugins register themselves here by augmenting this interface.
export interface Plugins {}

const registry = new Map<string, unknown>();

export function register<K extends keyof Plugins>(name: K, plugin: Plugins[K]): void {
  registry.set(name, plugin);
}

export function usePlugin<K extends keyof Plugins>(name: K): Plugins[K] {
  if (!registry.has(name)) throw new Error(`plugin ${name} is not registered`);
  return registry.get(name) as Plugins[K];
}
