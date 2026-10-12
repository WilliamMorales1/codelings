(* errors5: chaining results with let*

   Matching on every result gets deep fast. Result.bind runs the next
   step only if the previous one was Ok. Bound to `let*`, it reads like
   plain code:

     let* x = step1 in   (* stops here on Error *)
     ...

   The last expression must itself be a result.

   Task: make `add_ages` compile. *)

let ( let* ) = Result.bind

let parse_age s =
  match int_of_string_opt s with
  | Some n when n >= 0 -> Ok n
  | Some _ -> Error "negative"
  | None -> Error "not a number"

let add_ages a b =
  let* x = parse_age a in
  let* y = parse_age b in
  Ok (x + y)
