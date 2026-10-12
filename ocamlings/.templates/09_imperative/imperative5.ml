(* imperative5: while loops and Buffer

   `while cond do ... done` repeats while cond holds. Buffer builds a
   string piece by piece without copying everything on each `^`.

   Task: `repeat s n` should be s written n times. *)

let repeat s n =
  let b = Buffer.create 16 in
  let i = ref 0 in
  while !i <= n do
    Buffer.add_string b s;
    incr i
  done;
  Buffer.contents b
