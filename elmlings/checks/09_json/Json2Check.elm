module Json2Check exposing (failures)

{- HINT
   `User` takes the name first, then the age. Swap the two decoders so
   they line up with the alias.
-}

import Check
import Json.Decode as Decode
import Json2 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "decode Ann" (Decode.decodeString userDecoder "{\"name\": \"Ann\", \"age\": 30}" |> Result.toMaybe) (Just (User "Ann" 30))
        , Check.eq "age as text fails" (Decode.decodeString userDecoder "{\"name\": \"Ann\", \"age\": \"30\"}" |> Result.toMaybe) Nothing
        ]
