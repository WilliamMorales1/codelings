module Lists3 exposing (..)

{- Lists3: folding

   `List.foldl f start xs` walks the list from the left, calling
   `f element accumulator` and starting the accumulator at `start`.
   It is how you boil a list down to one value.

   Task: `product` multiplies every number, `backwards` reverses the
   list (without List.reverse).
-}


product : List Int -> Int
product =
    List.foldl (*) 1


backwards : List a -> List a
backwards =
    List.foldl (::) []
