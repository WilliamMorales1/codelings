(* HINT
   Look up the current count (Hashtbl.find_opt, 0 if missing), then
   store count + 1 with Hashtbl.replace. *)
let () =
  let t = frequencies [ "a"; "b"; "a"; "a" ] in
  Check.int {|count of "a"|} (Hashtbl.find t "a") 3;
  Check.int {|count of "b"|} (Hashtbl.find t "b") 1;
  Check.int "bindings" (Hashtbl.length t) 2
