(* HINT
   "index out of bounds": the loop runs one step too far, because
   `to` includes its upper bound. Stop at `Array.length a - 1`. *)
let () =
  Check.int "sum_array [|1; 2; 3|]" (sum_array [| 1; 2; 3 |]) 6;
  Check.int "sum_array [||]" (sum_array [||]) 0
