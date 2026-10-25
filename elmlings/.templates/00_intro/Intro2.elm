module Intro2 exposing (..)

{- Intro2: reading compiler errors

   Elm's compiler is famous for its error messages. When an exercise
   doesn't compile, read the whole message: it names the line, shows
   the types it found, and usually suggests the fix.

   Task: make `message` compile. It should be "You are 30 years old".
-}


age : Int
age =
    30


message : String
message =
    "You are " ++ age ++ " years old"
