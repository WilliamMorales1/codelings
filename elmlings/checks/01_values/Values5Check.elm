module Values5Check exposing (failures)

{- HINT
   The list holds Strings; make it a list of Chars with single quotes.
   `String.filter isVowel s` keeps only the vowels, then take its
   `String.length`.
-}

import Check
import Values5 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "isVowel 'E'" (isVowel 'E') True
        , Check.eq "isVowel 'x'" (isVowel 'x') False
        , Check.eq "countVowels \"Elm is neat\"" (countVowels "Elm is neat") 4
        ]
