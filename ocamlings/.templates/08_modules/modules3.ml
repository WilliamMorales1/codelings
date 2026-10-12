(* modules3: functors

   A functor is a function from modules to modules. Map.Make takes a
   module describing the key type (its `t` and `compare`) and returns a
   map module for that key. Int and String both fit.

   Task: make `count` compile, counting how often each word appears. *)

module Words = Map.Make (Int)

let count words =
  List.fold_left
    (fun m w ->
      let n = Option.value (Words.find_opt w m) ~default:0 in
      Words.add w (n + 1) m)
    Words.empty words
