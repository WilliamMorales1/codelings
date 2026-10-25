module Check exposing (all, eq, float)

{-| Check holds the assertions every check uses; each returns the failures it found.
-}


all : List (List String) -> List String
all =
    List.concat


eq : String -> a -> a -> List String
eq label actual expected =
    if actual == expected then
        []

    else
        [ mismatch label (Debug.toString expected) (Debug.toString actual) ]


float : String -> Float -> Float -> List String
float label actual expected =
    if abs (actual - expected) < 0.000000001 then
        []

    else
        [ mismatch label (String.fromFloat expected) (String.fromFloat actual) ]


mismatch : String -> String -> String -> String
mismatch label expected actual =
    label ++ "\n    expected: " ++ expected ++ "\n    got:      " ++ actual
