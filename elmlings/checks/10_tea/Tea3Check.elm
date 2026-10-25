module Tea3Check exposing (failures)

{- HINT
   For Add: `if String.isEmpty (String.trim model.draft) then model
   else { model | items = ..., draft = "" }`, adding the trimmed draft.
   For Remove: keep what's before and after the index,
   `List.take index model.items ++ List.drop (index + 1) model.items`.
-}

import Check
import Tea3 exposing (..)


failures : List String
failures =
    Check.all
        [ Check.eq "add milk" (run [ UpdateDraft " milk ", Add ]) { draft = "", items = [ "milk" ] }
        , Check.eq "blank draft" (run [ UpdateDraft "  ", Add ]) { draft = "  ", items = [] }
        , Check.eq "remove 0" (run [ UpdateDraft "a", Add, UpdateDraft "b", Add, Remove 0 ]) { draft = "", items = [ "b" ] }
        ]


run : List Msg -> Model
run msgs =
    List.foldl update init msgs
