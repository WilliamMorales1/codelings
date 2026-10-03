// @vitest-environment jsdom
import { cleanup, render } from '@testing-library/react';
import { afterEach, expect, test } from 'vitest';
import { Badge } from '@ex/02_react/react2.jsx';

afterEach(cleanup);

const html = (el) => render(el).container.innerHTML;

test('label with the default tone', () => {
  expect(html(<Badge label="New" />)).toBe('<span class="badge badge-neutral">New</span>');
});

test('explicit tone and a count', () => {
  expect(html(<Badge label="Inbox" tone="info" count={3} />)).toBe('<span class="badge badge-info">Inbox<b>3</b></span>');
});

test('a count of zero renders nothing extra', () => {
  expect(html(<Badge label="Spam" tone="warn" count={0} />)).toBe('<span class="badge badge-warn">Spam</span>');
});

/* HINT
The signature should be `function Badge({ label, tone = 'neutral', count = 0 })`
-- one destructured object, not three parameters.
For the count: `{count > 0 && <b>{count}</b>}`.
*/
