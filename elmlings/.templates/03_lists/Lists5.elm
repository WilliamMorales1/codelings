module Lists5 exposing (..)

{- Lists5: more of the List module

   `List.range a b` counts from a to b. `List.indexedMap` passes each
   element's index (from 0) as well. `List.sort`, `List.reverse` and
   `List.take` do what they say.

   Task: `numbered` gives "1. a", "2. b", ...; `squaresUpTo 3` is
   [1, 4, 9]; `topThree` gives the three largest, largest first.
-}


numbered : List String -> List String
numbered items =
    List.indexedMap (\i item -> String.fromInt i ++ ". " ++ item) items


squaresUpTo : Int -> List Int
squaresUpTo n =
    List.range 0 n |> List.map (\x -> x * x)


topThree : List Int -> List Int
topThree xs =
    List.take 3 (List.sort xs)
