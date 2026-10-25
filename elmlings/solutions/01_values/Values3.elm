module Values3 exposing (..)

{- Values3: strings

   The String module has what you'd expect: `String.toUpper`,
   `String.left`, `String.trim`, `String.isEmpty`, `String.length`.
   Function arguments go after the function, separated by spaces.

   Task: `shout "hey"` is "HEY!", `initials "Ada" "Lovelace"` is "AL",
   and `isBlank` is True for strings that are only whitespace.
-}


shout : String -> String
shout s =
    String.toUpper s ++ "!"


initials : String -> String -> String
initials first last =
    String.left 1 first ++ String.left 1 last


isBlank : String -> Bool
isBlank s =
    String.isEmpty (String.trim s)
