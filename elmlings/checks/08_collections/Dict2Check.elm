module Dict2Check exposing (failures)

{- HINT
   The first time a word is seen, `increment` gets `Nothing` and
   returns `Nothing`, so the word is never stored. A new word has been
   seen once: `Nothing -> Just 1`.
-}

import Check
import Dict
import Dict2 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "countWords \"the cat the Hat\"" (Dict.toList (countWords "the cat the Hat")) [ ( "cat", 1 ), ( "hat", 1 ), ( "the", 2 ) ]
        ]
