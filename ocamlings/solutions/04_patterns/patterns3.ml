(* patterns3: matching tuples, and case order

   You can match several values at once by matching a tuple. Since the
   first matching case wins, a general case placed above a specific one
   hides it. OCaml reports such a case as unused; here that is an error.

   Task: make fizzbuzz work. *)

let fizzbuzz n =
  match (n mod 3, n mod 5) with
  | 0, 0 -> "FizzBuzz"
  | 0, _ -> "Fizz"
  | _, 0 -> "Buzz"
  | _ -> string_of_int n
