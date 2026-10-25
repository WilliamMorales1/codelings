module Result3Check exposing (failures)

{- HINT
   `parseNumber` fails with a String; replace it:
   `parseNumber input |> Result.mapError (\_ -> Invalid "quantity")`.
   `Result.map2 Tuple.pair (requireField "item" item) (parseQuantity quantity)`
   gives the first error, or both values as a tuple.
-}

import Check
import Result3 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "order \"apple\" \"3\"" (order "apple" "3") (Ok ( "apple", 3 ))
        , Check.eq "order \"\" \"3\"" (order "" "3") (Err (Missing "item"))
        , Check.eq "order \"apple\" \"x\"" (order "apple" "x") (Err (Invalid "quantity"))
        , Check.eq "order \" \" \"x\"" (order " " "x") (Err (Missing "item"))
        ]
