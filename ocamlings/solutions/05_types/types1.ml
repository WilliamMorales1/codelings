(* types1: records

   A record type lists named fields with their types. Build a record
   with `{ x = ...; y = ... }` and read a field with `p.x`.

   Task: make it compile. *)

type point = { x : float; y : float }

let origin = { x = 0.; y = 0. }

let distance p = sqrt ((p.x *. p.x) +. (p.y *. p.y))
