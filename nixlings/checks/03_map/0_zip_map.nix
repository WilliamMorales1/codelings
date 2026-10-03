# HINT
# `lib.zipLists employees roles` gives [ { fst = "Alice"; snd = "Engineer"; } ... ].
# map a function with a destructuring argument over it:
# `map ({ fst, snd }: { name = fst; role = snd; }) ...`.
ex: ex.output.list == [
  { name = "Alice"; role = "Engineer"; }
  { name = "Bob"; role = "Manager"; }
  { name = "Charlie"; role = "Designer"; }
  { name = "David"; role = "Tester"; }
]
