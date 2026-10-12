(* patterns4: `function` and or-patterns

   `function | p1 -> e1 | p2 -> e2` is short for
   `fun x -> match x with | p1 -> e1 | p2 -> e2`.
   An or-pattern `'a' | 'e'` lets several patterns share one result.

   Task: `is_vowel` should accept all five lowercase vowels. *)

let is_vowel = function
  | 'a' | 'e' | 'i' | 'o' | 'u' -> true
  | _ -> false
