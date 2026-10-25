module Json2 exposing (..)

{- Json2: decoding objects

   `Decode.field "name" Decode.string` reads one field.
   `Decode.map2 f a b` runs two decoders and combines the results with
   f. A record alias's constructor is the perfect f: `User` takes the
   fields in the order the alias declares them.

   Task: make `userDecoder` compile.
-}

import Json.Decode as Decode


type alias User =
    { name : String
    , age : Int
    }


userDecoder : Decode.Decoder User
userDecoder =
    Decode.map2 User
        (Decode.field "age" Decode.int)
        (Decode.field "name" Decode.string)
