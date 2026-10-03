import fs from 'node:fs';
import path from 'node:path';
import { JSDOM, VirtualConsole } from 'jsdom';
import { onTestFinished } from 'vitest';
import { createServer } from '../lib/server.js';

export const ROOT = path.resolve(import.meta.dirname, '..');
export const SRC = path.resolve(ROOT, process.env.HTMXLINGS_SRC ?? 'exercises');

/** exDir resolves an exercise directory inside the tree the tests are pointed at. */
export const exDir = (chapter, name) => path.join(SRC, chapter, name);

export const readEx = (chapter, name, file) => fs.readFileSync(path.join(exDir(chapter, name), file), 'utf8');

export const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

/** until polls `fn` until it returns something truthy, failing with `what` after `timeout` ms. */
// Short enough for quick feedback while learning; verify-all.sh raises it because it runs every file at once.
const DEFAULT_TIMEOUT = Number(process.env.HTMXLINGS_TIMEOUT ?? 2500);

export async function until(fn, what = 'condition', timeout = DEFAULT_TIMEOUT) {
  const end = Date.now() + timeout;
  let last;
  for (;;) {
    try {
      last = await fn();
      if (last) return last;
    } catch (e) {
      last = e;
    }
    if (Date.now() > end) {
      throw new Error(`timed out after ${timeout}ms waiting for: ${what}${last instanceof Error ? ` (${last.message})` : ''}`);
    }
    await sleep(15);
  }
}

/** serve starts the exercise's server on a free port; closed automatically when the test ends. */
export async function serve(chapter, name) {
  const requests = [];
  const app = await createServer(exDir(chapter, name), { onRequest: (r) => requests.push(r) });
  const base = await app.listen(0);
  onTestFinished(() => app.close());
  const fetchEx = (p, init = {}) => {
    const { form, ...rest } = init;
    if (form) {
      rest.method ??= 'POST';
      rest.body = new URLSearchParams(form).toString();
      rest.headers = { 'content-type': 'application/x-www-form-urlencoded', ...(rest.headers ?? {}) };
    }
    return fetch(base + p, rest);
  };
  return { base, requests, fetch: fetchEx };
}

// jsdom gaps that htmx 2 trips over; each is a no-op or a spec default in real browsers.
function shim(window) {
  const evaluate = window.XPathExpression.prototype.evaluate;
  window.XPathExpression.prototype.evaluate = function (node, type = 0, result = null) {
    return evaluate.call(this, node, type, result);
  };
  window.Element.prototype.scrollIntoView = function () {};
  window.scrollTo = () => {};
}

/**
 * openPage serves an exercise and loads `pathname` in jsdom with htmx running for real.
 * Returns helpers for driving the page; everything is torn down when the test ends.
 */
export async function openPage(chapter, name, { pathname = '/', confirm = true, beforeLoad } = {}) {
  const srv = await serve(chapter, name);
  const errors = [];
  const vc = new VirtualConsole();
  vc.on('jsdomError', (e) => errors.push(e.message));
  vc.on('error', (...a) => errors.push(a.join(' ')));
  const dom = await JSDOM.fromURL(srv.base + pathname, {
    runScripts: 'dangerously',
    resources: 'usable',
    pretendToBeVisual: true,
    virtualConsole: vc,
    beforeParse(window) {
      shim(window);
      window.confirm = () => (typeof confirm === 'function' ? confirm() : confirm);
      beforeLoad?.(window);
    },
  });
  const window = dom.window;
  onTestFinished(() => window.close());
  if (window.document.readyState !== 'complete') {
    await new Promise((r) => window.addEventListener('load', r, { once: true }));
  }
  if (!window.htmx) throw new Error('htmx did not load: is <script src="/htmx.js"> still in the page?');
  const document = window.document;

  const $ = (sel) => document.querySelector(sel);
  const $$ = (sel) => [...document.querySelectorAll(sel)];
  const must = (sel) => {
    const el = typeof sel === 'string' ? $(sel) : sel;
    if (!el) throw new Error(`no element matches \`${sel}\``);
    return el;
  };
  /** htmxRequests are the requests the page made after it loaded (HX-Request: true). */
  const htmxRequests = () => srv.requests.filter((r) => r.headers['hx-request'] === 'true');

  return {
    window,
    document,
    errors,
    requests: srv.requests,
    htmxRequests,
    fetch: srv.fetch,
    base: srv.base,
    $,
    $$,
    text: (sel) => must(sel).textContent.replace(/\s+/g, ' ').trim(),
    click(sel) {
      must(sel).click();
    },
    /** type sets an input's value one character at a time, firing input and keyup like a person would. */
    type(sel, text, { clear = true } = {}) {
      const el = must(sel);
      if (clear) el.value = '';
      for (const ch of text) {
        el.value += ch;
        el.dispatchEvent(new window.KeyboardEvent('keydown', { key: ch, bubbles: true }));
        el.dispatchEvent(new window.Event('input', { bubbles: true }));
        el.dispatchEvent(new window.KeyboardEvent('keyup', { key: ch, bubbles: true }));
      }
    },
    fire(sel, type) {
      must(sel).dispatchEvent(new window.Event(type, { bubbles: true }));
    },
    submit(sel) {
      must(sel).requestSubmit();
    },
    /** idle waits until htmx has no request in flight and nothing is mid-swap or mid-settle. */
    async idle(extra = 60) {
      await until(
        () => !document.querySelector('.htmx-request, .htmx-swapping, .htmx-settling'),
        'htmx to finish its requests and swaps',
      );
      await sleep(extra);
    },
    until,
  };
}

/** waitForEvent resolves with the next `type` event on `target`. */
export const waitForEvent = (target, type, timeout = 2000) =>
  new Promise((resolve, reject) => {
    const t = setTimeout(() => reject(new Error(`no ${type} event within ${timeout}ms`)), timeout);
    target.addEventListener(type, (e) => (clearTimeout(t), resolve(e)), { once: true });
  });
