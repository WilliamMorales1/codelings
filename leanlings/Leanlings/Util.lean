namespace Leanlings

/-- A terminal style, stored as its raw ANSI escape prefix. -/
structure Style where
  code : String
  deriving Inhabited

def Style.reset : String := "\x1b[0m"

def bold   : Style := ⟨"\x1b[1m"⟩
def dim    : Style := ⟨"\x1b[2m"⟩
def red    : Style := ⟨"\x1b[31m"⟩
def green  : Style := ⟨"\x1b[32m"⟩
def yellow : Style := ⟨"\x1b[33m"⟩
def blue   : Style := ⟨"\x1b[34m"⟩
def cyan   : Style := ⟨"\x1b[36m"⟩

/-- Wrap `s` in `st`, unless the user asked for no colour. -/
def paint (st : Style) (s : String) : IO String := do
  match (← IO.getEnv "NO_COLOR") with
  | some _ => return s
  | none => return st.code ++ s ++ Style.reset

def say (st : Style) (s : String) : IO Unit := do
  IO.println (← paint st s)

/-- Pad `s` on the right so it is at least `n` characters wide. -/
def padTo (s : String) (n : Nat) : String :=
  s ++ "".pushn ' ' (n - s.length)

/-- An OSC 8 terminal hyperlink. Terminals that understand it show `label`
    and open `target` on click; the rest just print `label`. Suppressed under
    `NO_COLOR`, for the terminals that render escape sequences literally. -/
def hyperlink (target label : String) : IO String := do
  match (← IO.getEnv "NO_COLOR") with
  | some _ => return label
  | none => return s!"\x1b]8;;{target}\x1b\\{label}\x1b]8;;\x1b\\"

/-- A clickable `file://` link to a path on disk, labelled with `label`. -/
def fileLink (path : System.FilePath) (label : String) : IO String :=
  hyperlink s!"file://{path}" label

def clearScreen : IO Unit :=
  IO.print "\x1b[2J\x1b[H"

end Leanlings
