(* strings3: strings are immutable

   An OCaml string cannot change after it is built. To get a different
   string, make a new one: with String functions such as
   String.capitalize_ascii, String.map or String.concat, or through
   Bytes when you really need to edit in place.

   Task: `capitalize "ocaml"` should return "Ocaml". *)

let capitalize s = String.capitalize_ascii s
