(* HINT
   After fold_left you have one int, and List.filter wants a list.
   Filter before you sum. *)
let () = Check.int "process [1; 2; 3; 4]" (process [ 1; 2; 3; 4 ]) 20
