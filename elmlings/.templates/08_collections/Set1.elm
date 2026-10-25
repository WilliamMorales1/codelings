module Set1 exposing (..)

{- Set1: sets

   A `Set` holds each value at most once, kept sorted. `Set.fromList`
   and `Set.toList` convert, and `Set.intersect` keeps what two sets
   share. Only `comparable` values (numbers, strings, chars, and
   tuples or lists of them) can go in a Set or be Dict keys.

   Task: `unique` removes duplicates (sorted); `shared` lists what two
   lists have in common (sorted).
-}

import Set


unique : List comparable -> List comparable
unique xs =
    xs


shared : List comparable -> List comparable -> List comparable
shared xs ys =
    Debug.todo "shared"
