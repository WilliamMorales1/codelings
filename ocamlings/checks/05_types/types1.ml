(* HINT
   The fields are floats, and `0` is an int. Write `0.`. *)
let () =
  Check.float "distance origin" (distance origin) 0.;
  Check.float "distance {x = 3.; y = 4.}" (distance { x = 3.; y = 4. }) 5.
