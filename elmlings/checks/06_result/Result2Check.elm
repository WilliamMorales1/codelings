module Result2Check exposing (failures)

{- HINT
   `String.toInt input |> Result.fromMaybe ("not a number: " ++ input)`.
   `checkAge` returns a Result, so chain it with `Result.andThen`,
   not `Result.map`.
-}

import Check
import Result2 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "parseAge \"30\"" (parseAge "30") (Ok 30)
        , Check.eq "parseAge \"abc\"" (parseAge "abc") (Err "not a number: abc")
        , Check.eq "parseAge \"-5\"" (parseAge "-5") (Err "too young")
        , Check.eq "parseAge \"200\"" (parseAge "200") (Err "too old")
        ]
