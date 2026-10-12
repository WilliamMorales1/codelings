(* HINT
   This takes n squares and then throws the odd ones away. Filter
   first, then take n. *)
let () = Check.ints "even_squares 3" (even_squares 3) [ 4; 16; 36 ]
