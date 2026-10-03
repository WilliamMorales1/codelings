import Leanlings.Exercise

namespace Leanlings

inductive Outcome where
  /-- `lean` rejected the file (or the proof was left as `sorry`). -/
  | failed (output : String)
  /-- Compiles clean; `output` holds whatever `#eval` / `#print` produced. -/
  | passed (output : String)
  deriving Inhabited

def Outcome.isPassed : Outcome → Bool
  | .passed _ => true
  | _ => false

/-- Lean reports an unfinished proof as a *warning*, so check for it by hand. -/
private def usesSorry (s : String) : Bool :=
  decide ((s.splitOn "declaration uses").length > 1)

/-- Type-check one file with `lean`. Exercises depend on the core library only,
    so no `lake env` wrapper and no package download is needed. -/
def compile (path : System.FilePath) : IO (Bool × String) := do
  let res ← IO.Process.output { cmd := "lean", args := #[path.toString] }
  let out := (res.stdout ++ res.stderr).trimAscii.toString
  return (res.exitCode == 0 && !usesSorry out, out)

def Exercise.check (e : Exercise) : IO Outcome := do
  let (ok, out) ← compile e.path
  -- Report the file the way the learner sees it in their editor.
  let out := out.replace e.path.toString e.rel.toString
  return if ok then .passed out else .failed out

end Leanlings
