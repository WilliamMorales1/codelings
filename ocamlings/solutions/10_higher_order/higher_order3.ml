(* higher_order3: closures

   A function remembers the variables in scope where it was created.
   That lets a function carry private state: a ref created once and
   captured by the function lives as long as the function does.

   Task: each call of a counter should return 1, then 2, then 3. *)

let make_counter () =
  let n = ref 0 in
  fun () ->
    incr n;
    !n
