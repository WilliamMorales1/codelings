module Functions3 exposing (..)

{- Functions3: anonymous functions

   A function without a name is written `\x -> x + 1`. The backslash
   is meant to look like a lambda. They're handy for one-off
   arguments to `List.map` and friends.

   Task: `tripleAll` triples every number, `exclaimAll` adds "!" to
   every string.
-}


tripleAll : List Int -> List Int
tripleAll xs =
    List.map (\x -> x * 3) xs


exclaimAll : List String -> List String
exclaimAll words =
    List.map (\w -> w ++ "!") words
