module Json4Check exposing (failures)

{- HINT
   Encode the age with `Encode.int user.age`, and add a third field:
   `( "admin", Encode.bool user.admin )`.
-}

import Check
import Json4 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "toJson Ann" (toJson (User "Ann" 30 True)) "{\"name\":\"Ann\",\"age\":30,\"admin\":true}"
        ]
