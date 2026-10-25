module Json3Check exposing (failures)

{- HINT
   `(Decode.at [ "author", "name" ] Decode.string)` for the author.
   For tags: `Decode.oneOf [ Decode.field "tags" (Decode.list
   Decode.string), Decode.succeed [] ]`.
-}

import Check
import Json.Decode as Decode
import Json3 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "post with tags" (Decode.decodeString postDecoder "{\"title\": \"Hi\", \"tags\": [\"elm\"], \"author\": {\"name\": \"Ann\"}}" |> Result.toMaybe) (Just (Post "Hi" [ "elm" ] "Ann"))
        , Check.eq "post without tags" (Decode.decodeString postDecoder "{\"title\": \"Yo\", \"author\": {\"name\": \"Bo\"}}" |> Result.toMaybe) (Just (Post "Yo" [] "Bo"))
        ]
