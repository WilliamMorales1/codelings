(* HINT
   prepend: the element goes on the left of `::`.
   append_one: wrap the element in a list of its own, `[ x ]`. *)
let () =
  Check.ints "prepend 0 [1; 2]" (prepend 0 [ 1; 2 ]) [ 0; 1; 2 ];
  Check.ints "append_one [1; 2] 3" (append_one [ 1; 2 ] 3) [ 1; 2; 3 ]
