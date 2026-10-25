module Lists2 exposing (..)

{- Lists2: map and filter

   `List.map f xs` applies f to every element. `List.filter keep xs`
   keeps the elements where `keep` is True. Careful with argument
   order: `modBy 2 n` is n modulo 2, not 2 modulo n.

   Task: `evens` keeps the even numbers, `lengths` gives the length of
   every string.
-}


evens : List Int -> List Int
evens =
    List.filter (\n -> modBy n 2 == 0)


lengths : List String -> List Int
lengths words =
    Debug.todo "lengths"
