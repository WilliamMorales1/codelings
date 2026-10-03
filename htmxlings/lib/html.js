// Tiny HTML templating for the exercise handlers: interpolated values are escaped unless they are Html already.

/** Html marks a string as trusted markup so html`` does not escape it again. */
export class Html {
  constructor(s) {
    this.s = s;
  }
  toString() {
    return this.s;
  }
  // A registry symbol, so the server recognises Html even if this module is loaded twice.
  get [Symbol.for('htmxlings.html')]() {
    return true;
  }
}

/** esc escapes the five HTML-special characters. */
export const esc = (v) =>
  String(v ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]);

const isHtml = (v) => v != null && v[Symbol.for('htmxlings.html')] === true;

const part = (v) => (isHtml(v) ? v.s : Array.isArray(v) ? v.map(part).join('') : v === false || v == null ? '' : esc(v));

/** html is a tagged template: html`<li>${name}</li>` escapes `name`; arrays of html`` results are joined. */
export const html = (strings, ...values) => new Html(strings.reduce((out, s, i) => out + part(values[i - 1]) + s));

/** raw trusts a string as markup. */
export const raw = (s) => new Html(String(s));
