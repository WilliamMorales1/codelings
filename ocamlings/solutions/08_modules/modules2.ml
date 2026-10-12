(* modules2: signatures

   A signature (`module type`) says what a module must provide and what
   the outside may see. `module Stack : STACK = struct ... end` is
   checked against it, and anything not listed, including how `t` is
   built, stays hidden.

   Task: make Stack match its signature. *)

module type STACK = sig
  type t
  val empty : t
  val push : int -> t -> t
  val pop : t -> (int * t) option
end

module Stack : STACK = struct
  type t = int list
  let empty = []
  let push x s = x :: s

  let pop s =
    match s with
    | [] -> None
    | x :: rest -> Some (x, rest)
end
