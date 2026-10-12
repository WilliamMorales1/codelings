(* HINT
   Use `&&` in is_teen. In same_name, two strings built separately
   are never `==`, even with the same letters: use `=`. *)
let () =
  Check.bool "is_teen 15" (is_teen 15) true;
  Check.bool "is_teen 20" (is_teen 20) false;
  Check.bool "is_teen 12" (is_teen 12) false;
  Check.bool {|same_name "ada" (String.lowercase_ascii "ADA")|}
    (same_name "ada" (String.lowercase_ascii "ADA")) true;
  Check.bool {|same_name "ada" "bob"|} (same_name "ada" "bob") false
