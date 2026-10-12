(* HINT
   The order is backwards: g runs first, so it is the inner call. *)
let () =
  let add1 x = x + 1 and double x = x * 2 in
  Check.int "compose add1 double 5" (compose add1 double 5) 11;
  Check.int "compose double add1 5" (compose double add1 5) 12
