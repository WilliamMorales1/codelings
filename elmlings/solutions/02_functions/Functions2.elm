module Functions2 exposing (..)

{- Functions2: partial application

   Every Elm function takes one argument at a time. `add` has type
   `Int -> Int -> Int`: give it one Int and you get back an
   `Int -> Int` function waiting for the other. Operators are
   functions too when wrapped in parentheses: `(+) 1 2` is 3.

   Task: define `increment` and `double` by giving `add` and `(*)`
   only their first argument.
-}


add : Int -> Int -> Int
add a b =
    a + b


increment : Int -> Int
increment =
    add 1


double : Int -> Int
double =
    (*) 2
