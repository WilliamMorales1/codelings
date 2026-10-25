module Types5 exposing (..)

{- Types5: tuples

   `( 1, "one" )` is a tuple: a fixed number of values (two or three)
   that can have different types. Patterns take tuples apart right in
   the argument list.

   Task: `swap` exchanges the two parts; `divMod 17 5` is ( 3, 2 ).
-}


swap : ( a, b ) -> ( b, a )
swap ( a, b ) =
    ( a, b )


divMod : Int -> Int -> ( Int, Int )
divMod a b =
    Debug.todo "divMod"
