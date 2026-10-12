(* types3: variants

   A variant type is a set of alternatives, each with optional data:
   `Circle of float`. Matching on a variant must handle every
   constructor; the compiler tells you which one you forgot.

   Task: finish `area`. *)

type shape =
  | Circle of float
  | Rect of float * float
  | Square of float

let area s =
  match s with
  | Circle r -> Float.pi *. r *. r
  | Rect (w, h) -> w *. h
  | Square side -> side *. side
