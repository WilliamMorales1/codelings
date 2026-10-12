(* HINT
   `0, _` already matches `0, 0`, so the FizzBuzz case can never run.
   Move it to the top. *)
let () =
  Check.strs "fizzbuzz 1..15"
    (List.map fizzbuzz [ 1; 3; 5; 15 ])
    [ "1"; "Fizz"; "Buzz"; "FizzBuzz" ]
