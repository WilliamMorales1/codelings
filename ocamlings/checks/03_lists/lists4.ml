(* HINT
   count_evens counts everything: filter first,
   List.filter (fun x -> x mod 2 = 0) l.
   product's step function ignores x; multiply it into acc. *)
let () =
  Check.int "count_evens [1; 2; 3; 4; 6]" (count_evens [ 1; 2; 3; 4; 6 ]) 3;
  Check.int "product [2; 3; 4]" (product [ 2; 3; 4 ]) 24
