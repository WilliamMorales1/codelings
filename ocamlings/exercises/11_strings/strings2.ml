(* strings2: splitting

   String.split_on_char cuts at every separator, so two spaces in a row
   give an empty string between them. String.trim drops whitespace at
   both ends.

   Task: `words` should return only the actual words. *)

let words s = String.split_on_char ' ' s
