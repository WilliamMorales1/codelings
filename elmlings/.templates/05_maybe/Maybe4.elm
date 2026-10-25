module Maybe4 exposing (..)

{- Maybe4: lists of maybes

   `List.filterMap f` maps and keeps only the `Just` results, already
   unwrapped. `List.head` of a filtered list finds the first match.

   Task: `parseAll` keeps the strings that are numbers; `firstEven`
   finds the first even number, if any.
-}


parseAll : List String -> List Int
parseAll =
    List.map String.toInt


firstEven : List Int -> Maybe Int
firstEven xs =
    Debug.todo "firstEven"
