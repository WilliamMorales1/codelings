(* HINT
   `a +. b` is a float, so the division must be the float one, `/.`,
   and the divisor a float literal, `2.`. *)
let () =
  Check.float "average 1. 2." (average 1. 2.) 1.5;
  Check.float "average 10. 20." (average 10. 20.) 15.
