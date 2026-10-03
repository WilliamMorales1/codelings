import { expect, expectTypeOf, it } from 'vitest';
import '@ex/07_classes_modules/merging1/analytics.ts';
import { usePlugin } from '@ex/07_classes_modules/merging1/host.ts';
import type { Analytics } from '@ex/07_classes_modules/merging1/analytics.ts';

it('the plugin is registered and typed', () => {
  const a = usePlugin('analytics');
  expectTypeOf(a).toEqualTypeOf<Analytics>();
  a.track('signup');
  expect(a.events).toEqual(['signup']);
});

it('unknown plugins are still rejected', () => {
  // @ts-expect-error nobody registered "payments"
  expect(() => usePlugin('payments')).toThrow();
});

/* HINT
Add to analytics.ts, anywhere at the top level:
  declare module './host.ts' {
    interface Plugins {
      analytics: Analytics;
    }
  }
The file must be a module (it is: it has imports) for this to be an
augmentation rather than a brand-new ambient module declaration.
*/
