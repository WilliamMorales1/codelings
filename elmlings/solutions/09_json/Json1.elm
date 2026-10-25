module Json1 exposing (..)

{- Json1: decoding

   Elm doesn't trust JSON. A `Decoder a` describes what you expect,
   and `Decode.decodeString decoder text` gives `Ok a` or an `Err`
   explaining what didn't match. Decoders combine: `Decode.list
   Decode.int` decodes a list of ints.

   Task: `parseNumbers "[1, 2, 3]"` is Just [1, 2, 3].
-}

import Json.Decode as Decode


parseNumbers : String -> Maybe (List Int)
parseNumbers json =
    Decode.decodeString (Decode.list Decode.int) json |> Result.toMaybe
