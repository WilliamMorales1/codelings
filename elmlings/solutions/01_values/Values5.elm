module Values5 exposing (..)

{- Values5: characters

   A Char is written in single quotes ('a') and a String in double
   quotes ("a"). They are different types, so a list of Strings
   can't contain a Char.

   Task: `isVowel` takes a Char (either case) and `countVowels` counts
   the vowels in a String.
-}


isVowel : Char -> Bool
isVowel c =
    List.member (Char.toLower c) [ 'a', 'e', 'i', 'o', 'u' ]


countVowels : String -> Int
countVowels s =
    String.length (String.filter isVowel s)
