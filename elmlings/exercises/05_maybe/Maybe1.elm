module Maybe1 exposing (..)

{- Maybe1: values that might be missing

   Elm has no null. A value that might be absent has type `Maybe a`:
   either `Just a` or `Nothing`. `String.toInt "42"` is `Just 42`;
   `String.toInt "abc"` is `Nothing`. `Maybe.withDefault` picks a
   fallback.

   Task: `parseAge` gives 0 for bad input; `firstOr` gives the first
   element, or the fallback for an empty list.
-}


parseAge : String -> Int
parseAge input =
    String.toInt input


firstOr : a -> List a -> a
firstOr fallback xs =
    Debug.todo "firstOr"
