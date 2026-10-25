module Types1 exposing (..)

{- Types1: records

   A record groups named fields: `{ name = "Ada", age = 36 }`. A type
   alias gives its type a name, and also makes a constructor function:
   `Person "Ada" 36` builds the same record, fields in order.

   Task: make `greet` and `ada` compile.
-}


type alias Person =
    { name : String
    , age : Int
    }


greet : Person -> String
greet person =
    "Hi, " ++ person.fullName ++ " (" ++ String.fromInt person.age ++ ")"


ada : Person
ada =
    { name = "Ada" }
