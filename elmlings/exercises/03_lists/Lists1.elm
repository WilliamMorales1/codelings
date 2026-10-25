module Lists1 exposing (..)

{- Lists1: building lists

   `x :: xs` puts one element in front of a list. `xs ++ ys` joins two
   lists. Every element of a list has the same type.

   Task: fix `prepend` and `joinLists`.
-}


prepend : a -> List a -> List a
prepend x xs =
    xs :: x


joinLists : List a -> List a -> List a
joinLists xs ys =
    xs :: ys
