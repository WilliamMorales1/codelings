(* lists4: the List module

   Most list code is a call to List: List.filter keeps the elements a
   test accepts, List.length counts, and List.fold_left walks the list
   carrying an accumulator:

     List.fold_left (fun acc x -> acc + x) 0 [1; 2; 3] = 6

   Task: fix `count_evens` and `product`. *)

let count_evens l = List.length l

let product l = List.fold_left (fun acc x -> acc) 1 l
