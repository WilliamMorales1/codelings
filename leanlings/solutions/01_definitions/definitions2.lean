-- definitions2.lean
--
-- Types are checked, and Lean will not quietly convert between them.
-- One of these definitions promises the wrong type.

def cityName : String := "Reykjavik"
def cityPopulation : Nat := 139875

#guard cityName == "Reykjavik"
#guard cityPopulation > 100000
