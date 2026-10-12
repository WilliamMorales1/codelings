(* higher_order4: lazy sequences

   A Seq computes its elements only when asked, so it can be infinite:
   `Seq.ints 1` is 1, 2, 3, ... forever. Seq.map and Seq.filter stay
   lazy; Seq.take n cuts the sequence off, and List.of_seq forces it.

   Task: `even_squares n` should be the first n even squares. *)

let even_squares n =
  Seq.ints 1
  |> Seq.map (fun x -> x * x)
  |> Seq.take n
  |> Seq.filter (fun x -> x mod 2 = 0)
  |> List.of_seq
