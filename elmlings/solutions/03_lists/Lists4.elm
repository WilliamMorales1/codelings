module Lists4 exposing (..)

{- Lists4: case on lists

   `case xs of` takes a list apart: `[]` is empty, `[ x ]` is exactly
   one element, `x :: rest` is at least one. The compiler insists that
   every possible list is handled.

   Task: make `describe` compile, and fix `sumFirstTwo` for a list of
   one element (it should give that element).
-}


describe : List a -> String
describe xs =
    case xs of
        [] ->
            "empty"

        [ _ ] ->
            "one"

        _ :: _ :: _ ->
            "many"


sumFirstTwo : List Int -> Int
sumFirstTwo xs =
    case xs of
        a :: b :: _ ->
            a + b

        [ a ] ->
            a

        [] ->
            0
