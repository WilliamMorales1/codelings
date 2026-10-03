import Leanlings.Util

namespace Leanlings

/-- One exercise on disk. `name` is the file stem, `chapter` the directory it lives in. -/
structure Exercise where
  chapter : String
  name    : String
  path    : System.FilePath
  /-- The same file, written relative to the project root, for display. -/
  rel     : System.FilePath
  deriving Repr, Inhabited

def Exercise.solution (e : Exercise) : System.FilePath :=
  ("solutions" : System.FilePath) / e.chapter / (e.name ++ ".lean")

/-- Walk upwards from the current directory until we find the project root. -/
def findRoot : IO System.FilePath := do
  let mut dir ← IO.currentDir
  for _ in [0:8] do
    if ← (dir / "exercises").isDir then
      return dir
    match dir.parent with
    | some p => dir := p
    | none   => break
  throw <| IO.userError "could not find an `exercises/` directory; run leanlings from the project root"

private def sortedNames (dir : System.FilePath) (keep : IO.FS.DirEntry → IO Bool) :
    IO (Array IO.FS.DirEntry) := do
  let mut out := #[]
  for entry in ← dir.readDir do
    if ← keep entry then
      out := out.push entry
  return out.qsort (fun a b => decide (a.fileName < b.fileName))

/-- All exercises, in curriculum order: chapters sorted by name, files sorted within a chapter. -/
def discover (root : System.FilePath) : IO (Array Exercise) := do
  let mut out := #[]
  let chapters ← sortedNames (root / "exercises") (fun e => e.path.isDir)
  for ch in chapters do
    let files ← sortedNames ch.path (fun e => pure (e.path.extension == some "lean"))
    for f in files do
      let name := f.path.fileStem.getD f.fileName
      let rel := ("exercises" : System.FilePath) / ch.fileName / f.fileName
      out := out.push { chapter := ch.fileName, name := name, path := f.path, rel := rel }
  return out

/-- Text of the `/- HINT ... -/` block, if the exercise has one. -/
def Exercise.hint (e : Exercise) : IO (Option String) := do
  let src ← IO.FS.readFile e.path
  match src.splitOn "/- HINT" with
  | _ :: rest :: _ =>
    match rest.splitOn "-/" with
    | body :: _ => return some body.trimAscii.toString
    | [] => return none
  | _ => return none

/-- Find the exercise whose name (or `chapter/name`) the user typed. -/
def findByName (exs : Array Exercise) (needle : String) : Option Exercise :=
  let needle := needle.replace ".lean" ""
  exs.find? fun e =>
    e.name == needle || s!"{e.chapter}/{e.name}" == needle || e.path.toString == needle

end Leanlings
