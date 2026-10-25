module Json3 exposing (..)

{- Json3: nested and optional fields

   `Decode.at [ "a", "b" ] d` reads a field inside a field.
   `Decode.oneOf` tries decoders in order and takes the first that
   works; `Decode.succeed x` always works, which makes a default.

   Task: the author's name lives at author.name, and a post without a
   "tags" field has no tags.
-}

import Json.Decode as Decode


type alias Post =
    { title : String
    , tags : List String
    , author : String
    }


postDecoder : Decode.Decoder Post
postDecoder =
    Decode.map3 Post
        (Decode.field "title" Decode.string)
        (Decode.oneOf
            [ Decode.field "tags" (Decode.list Decode.string)
            , Decode.succeed []
            ]
        )
        (Decode.at [ "author", "name" ] Decode.string)
