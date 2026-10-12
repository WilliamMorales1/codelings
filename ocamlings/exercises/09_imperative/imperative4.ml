(* imperative4: hash tables

   Hashtbl is a mutable hash map. Careful: Hashtbl.add does not replace
   an existing binding, it hides it behind a new one. Hashtbl.replace
   overwrites. Hashtbl.find_opt looks a key up without raising.

   Task: `frequencies` should count how often each word appears. *)

let frequencies words =
  let t = Hashtbl.create 16 in
  List.iter (fun w -> Hashtbl.add t w 1) words;
  t
