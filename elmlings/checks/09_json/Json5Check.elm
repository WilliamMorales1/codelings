module Json5Check exposing (failures)

{- HINT
   Add a `"rect" ->` branch before the catch-all, using `Decode.map2
   Rect` with the "w" and "h" fields.
-}

import Check
import Json.Decode as Decode
import Json5 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "circle" (Decode.decodeString shapeDecoder "{\"kind\": \"circle\", \"r\": 1.5}" |> Result.toMaybe) (Just (Circle 1.5))
        , Check.eq "rect" (Decode.decodeString shapeDecoder "{\"kind\": \"rect\", \"w\": 2, \"h\": 3}" |> Result.toMaybe) (Just (Rect 2 3))
        , Check.eq "unknown kind" (Decode.decodeString shapeDecoder "{\"kind\": \"blob\"}" |> Result.toMaybe) Nothing
        ]
