(* HINT
   Extend the first case: `| 'a' | 'e' | 'i' | 'o' | 'u' -> true`. *)
let () =
  Check.str "vowels kept from \"education\""
    (String.of_seq (Seq.filter is_vowel (String.to_seq "education")))
    "euaio";
  Check.bool "is_vowel 'z'" (is_vowel 'z') false
