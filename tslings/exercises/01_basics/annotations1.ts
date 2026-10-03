// annotations1 — Type annotations
//
// Under `strict`, TypeScript refuses to guess the type of a function
// parameter: an unannotated parameter is an implicit `any`, which is an error
// (TS7006). Variables usually don't need annotations — their type is inferred
// from the value — but parameters do.
//
// Task: annotate every parameter. Add return types too; they turn "the
// function body changed by accident" into an error at the function instead
// of at every caller.
//

export function formatPrice(cents, currency) {
  return `${(cents / 100).toFixed(2)} ${currency}`;
}

export function isAdult(age) {
  return age >= 18;
}

export function repeat(text, times) {
  return Array.from({ length: times }, () => text).join('');
}
