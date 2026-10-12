(* HINT
   Go to an int, add one, come back:
   Char.chr (Char.code c + 1). *)
let () =
  Check.char "next_letter 'a'" (next_letter 'a') 'b';
  Check.char "next_letter 'y'" (next_letter 'y') 'z'
