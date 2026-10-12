(* HINT
   go walks the list but drops every x. Push it onto the
   accumulator: `go (x :: acc) rest`. *)
let () =
  Check.ints "rev [1; 2; 3]" (rev [ 1; 2; 3 ]) [ 3; 2; 1 ];
  Check.int "length (rev (1..1_000_000))"
    (List.length (rev (List.init 1_000_000 Fun.id))) 1_000_000
