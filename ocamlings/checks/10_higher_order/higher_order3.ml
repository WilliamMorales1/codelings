(* HINT
   A new ref is made on every call, so it always starts at 0. Create
   it once, before `fun () ->`, so the function captures it. *)
let () =
  let c = make_counter () in
  let first = c () in
  let second = c () in
  let third = c () in
  Check.ints "three calls" [ first; second; third ] [ 1; 2; 3 ];
  Check.int "a new counter starts over" (make_counter () ()) 1
