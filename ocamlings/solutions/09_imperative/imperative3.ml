(* imperative3: arrays and for loops

   Arrays are fixed-size and mutable: `a.(i)` reads, `a.(i) <- v` writes,
   indices run from 0 to `Array.length a - 1`. `for i = lo to hi do ...
   done` includes both ends.

   Task: fix `sum_array`. *)

let sum_array a =
  let total = ref 0 in
  for i = 0 to Array.length a - 1 do
    total := !total + a.(i)
  done;
  !total
