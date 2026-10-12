(* functions5: recursion

   A function can call itself only if it is declared with `let rec`.
   A plain `let` cannot see its own name while it is being defined.

   Task: make `factorial` compile and work. *)

let factorial n = if n <= 1 then 1 else n * factorial (n - 1)
