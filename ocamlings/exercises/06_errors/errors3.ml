(* errors3: result

   `('a, 'e) result` is either `Ok value` or `Error reason`. Unlike
   option, the failure says what went wrong.

   Task: make `parse_age` handle input that is not a number at all. *)

let parse_age s =
  match int_of_string_opt s with
  | Some n when n >= 0 -> Ok n
  | Some _ -> Error "negative"
