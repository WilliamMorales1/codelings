(* HINT
   Read the cell before adding: `!counter + 1`. (`incr counter` does
   the same thing.) *)
let () =
  tick ();
  tick ();
  Check.int "!counter after two ticks" !counter 2
