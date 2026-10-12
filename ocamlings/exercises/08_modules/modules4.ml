(* modules4: writing a functor

   `module ListShow (S : SHOW) = struct ... end` is a functor of your
   own: give it any module that has a type `t` and a `show`, and it
   returns a module that can show lists of `t`.

   Task: the argument for BoolList is missing something. *)

module type SHOW = sig
  type t
  val show : t -> string
end

module ListShow (S : SHOW) = struct
  let show l = "[" ^ String.concat ", " (List.map S.show l) ^ "]"
end

module IntList = ListShow (struct
  type t = int
  let show = string_of_int
end)

module BoolList = ListShow (struct
  type t = bool
end)
