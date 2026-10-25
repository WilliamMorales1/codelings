module Functions5 exposing (..)

{- Functions5: composition

   `f >> g` is a new function that runs f, then g. `g << f` is the
   same thing written the other way round. The arrow points the way
   the value flows.

   Task: `isLong` is True for strings longer than 5 characters, and
   `cleanAll` trims and lowercases every string.
-}


isLong : String -> Bool
isLong =
    String.length << (\n -> n > 5)


cleanAll : List String -> List String
cleanAll =
    List.map String.toLower
