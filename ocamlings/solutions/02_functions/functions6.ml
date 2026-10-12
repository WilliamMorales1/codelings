(* functions6: labelled and optional arguments

   `~width` declares a labelled argument; callers write `~width:3` and
   may pass labelled arguments in any order. `?(greeting = "Hello")`
   declares an optional argument with a default value.

   Task: make `area` take labelled ~width and ~height, and give `greet`
   an optional ?greeting that defaults to "Hello". *)

let area ~width ~height = width * height

let greet ?(greeting = "Hello") name = greeting ^ ", " ^ name
