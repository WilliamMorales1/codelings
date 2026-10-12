(* values3: strings

   Strings join with `^`, not `+`. The String module holds the rest:
   String.length, String.uppercase_ascii, String.sub and friends.

   Task: make `shout "hi"` return "HI!". *)

let shout s = String.uppercase_ascii s ^ "!"
