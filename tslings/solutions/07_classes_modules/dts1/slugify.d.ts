// dts1 — declarations for slugify.js (see that file for the task).

export interface SlugifyOptions {
  /** Placed between words. Default "-". */
  separator?: string;
  /** Lower-case the result. Default true. */
  lower?: boolean;
  /** Cut the slug to at most this many characters. */
  maxLength?: number;
}

export declare function slugify(text: string, options?: SlugifyOptions): string;

export declare const version: string;
