module Json4 exposing (..)

{- Json4: encoding

   `Json.Encode` goes the other way: `Encode.object` takes a list of
   field names and encoded values, and `Encode.encode 0 value` turns
   it into a compact string. The types must match what the other side
   expects: an age is a number, not text.

   Task: `toJson` should give {"name":"Ann","age":30,"admin":true}.
-}

import Json.Encode as Encode


type alias User =
    { name : String
    , age : Int
    , admin : Bool
    }


encodeUser : User -> Encode.Value
encodeUser user =
    Encode.object
        [ ( "name", Encode.string user.name )
        , ( "age", Encode.int user.age )
        , ( "admin", Encode.bool user.admin )
        ]


toJson : User -> String
toJson user =
    Encode.encode 0 (encodeUser user)
