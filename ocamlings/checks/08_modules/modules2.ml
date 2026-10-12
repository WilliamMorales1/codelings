(* HINT
   "The value pop is required but not provided". Write it inside the
   struct: an empty list gives None, `x :: rest` gives Some (x, rest). *)
let () =
  let s = Stack.(push 2 (push 1 empty)) in
  match Stack.pop s with
  | Some (top, rest) ->
      Check.int "top" top 2;
      Check.ok "pop after two pops is None"
        (match Stack.pop rest with
         | Some (_, rest) -> Stack.pop rest = None
         | None -> false)
  | None -> Check.fail "pop" "\n  got None from a stack of two"
