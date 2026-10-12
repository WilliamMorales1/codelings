(* HINT
   "The record field balance is not mutable". Declare it so:
   `mutable balance : int`. *)
let () =
  let a = { owner = "ada"; balance = 10 } in
  deposit a 5;
  deposit a 7;
  Check.int "balance" a.balance 22;
  Check.str "owner" a.owner "ada"
