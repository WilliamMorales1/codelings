module Functions1 exposing (..)

{- Functions1: type annotations

   The line above a definition, `name : Type`, is its type
   annotation. It's optional, but when present the compiler holds the
   definition to it. `Int -> Int` means "takes an Int, gives an Int".

   Task: the annotation on `cube` is wrong. Fix it.
-}


square : Int -> Int
square x =
    x * x


cube : Int -> String
cube x =
    x * square x
