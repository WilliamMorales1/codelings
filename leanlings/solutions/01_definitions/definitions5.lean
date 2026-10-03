-- definitions5.lean
--
-- A `namespace` prefixes every name declared inside it. Outside the
-- namespace you either write the full name, `Physics.speedOfLight`, or bring
-- the short names into scope with `open Physics`.
--
-- The `#guard` at the bottom uses the short name but the `open` is missing.

namespace Physics

def speedOfLight : Nat := 299792458

end Physics

open Physics

#guard speedOfLight == 299792458
