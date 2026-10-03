import Leanlings.Check

namespace Leanlings

/-! ## Reporting -/

def progressBar (done total : Nat) : IO String := do
  let width := 32
  let filled := if total == 0 then 0 else width * done / total
  let bar := "".pushn '#' filled ++ "".pushn '-' (width - filled)
  let bar ← paint green bar
  return s!"Progress: [{bar}] {done}/{total}"

/-- Print the compiler output, indented so it is clearly the exercise talking. -/
def showOutput (out : String) : IO Unit := do
  if out.isEmpty then return
  for line in out.splitOn "\n" do
    IO.println s!"    {line}"

def showHint (e : Exercise) : IO Unit := do
  match ← e.hint with
  | none => say dim "(this exercise has no hint)"
  | some h =>
    say cyan "Hint:"
    for line in h.splitOn "\n" do
      IO.println s!"    {line.trimAscii}"

/-- Render one exercise result. Returns `true` when the learner may move on. -/
def report (e : Exercise) (o : Outcome) : IO Bool := do
  match o with
  | .failed out =>
    say red s!"x {e.chapter}/{e.name} does not compile."
    IO.println s!"  File: {← fileLink e.path e.rel.toString}"
    showOutput out
    IO.println ""
    showHint e
    return false
  | .passed out =>
    say green s!"v {e.chapter}/{e.name} passes!"
    showOutput out
    return true

/-! ## Progress -/

/-- A cheap change-token for a file: its mtime plus its size. -/
private def stamp (path : System.FilePath) : IO String := do
  try
    let md ← path.metadata
    return s!"{md.modified.sec}.{md.modified.nsec}:{md.byteSize}"
  catch _ => return "gone"

private def Exercise.id (e : Exercise) : String := s!"{e.chapter}/{e.name}"

/-- Passing exercises are remembered with their file stamp, one `id stamp` per line,
    so editing a solved exercise puts it back in the queue. -/
private def progressFile (root : System.FilePath) : System.FilePath := root / ".leanlings-progress"

private def loadProgress (root : System.FilePath) : IO (List (String × String)) := do
  let f := progressFile root
  if !(← f.pathExists) then return []
  let src ← IO.FS.readFile f
  return src.splitOn "\n" |>.filterMap fun l =>
    match l.splitOn " " with
    | [id, st] => some (id, st)
    | _ => none

def isDone (root : System.FilePath) (e : Exercise) : IO Bool := do
  let st ← stamp e.path
  return (← loadProgress root).contains (e.id, st)

/-- Remember a pass, or forget an earlier one when the exercise no longer passes. -/
def record (root : System.FilePath) (e : Exercise) (o : Outcome) : IO Unit := do
  let st ← stamp e.path
  let rest := (← loadProgress root).filter (·.1 != e.id)
  let entries := if o.isPassed then rest ++ [(e.id, st)] else rest
  IO.FS.writeFile (progressFile root) (String.join (entries.map fun (i, s) => s!"{i} {s}\n"))

/-- Check an exercise and remember the result. -/
def checkAndRecord (root : System.FilePath) (e : Exercise) : IO Outcome := do
  let o ← e.check
  record root e o
  return o

/-! ## Commands -/

def cmdList (root : System.FilePath) : IO UInt32 := do
  let exs ← discover root
  let mut done := 0
  for e in exs do
    let ok ← isDone root e
    let (st, label) := if ok then (green, "DONE   ") else (yellow, "PENDING")
    if ok then done := done + 1
    IO.println s!"{← paint st label}  {padTo (e.chapter ++ "/" ++ e.name) 34} {← fileLink e.path e.rel.toString}"
  IO.println ""
  IO.println (← progressBar done exs.size)
  return 0

/-- The first exercise that is not finished. -/
def nextPending (root : System.FilePath) (exs : Array Exercise) : IO (Option (Exercise × Outcome)) := do
  for e in exs do
    if ← isDone root e then continue
    let o ← checkAndRecord root e
    if !o.isPassed then
      return some (e, o)
  return none

def cmdVerify (root : System.FilePath) : IO UInt32 := do
  let exs ← discover root
  match ← nextPending root exs with
  | none =>
    say green s!"All {exs.size} exercises complete. You have out-Leaned the Lean."
    return 0
  | some (e, o) =>
    let mut done := 0
    for x in exs do
      if x.name == e.name && x.chapter == e.chapter then break
      done := done + 1
    IO.println (← progressBar done exs.size)
    IO.println ""
    let _ ← report e o
    return 1

def cmdRun (root : System.FilePath) (name : Option String) : IO UInt32 := do
  let exs ← discover root
  let target ← match name with
    | some n => match findByName exs n with
      | some e => pure e
      | none => throw <| IO.userError s!"no exercise named `{n}` (try `leanlings list`)"
    | none => match ← nextPending root exs with
      | some (e, _) => pure e
      | none =>
        say green "Nothing left to run: every exercise passes."
        return 0
  let o ← checkAndRecord root target
  return if ← report target o then 0 else 1

def cmdHint (root : System.FilePath) (name : Option String) : IO UInt32 := do
  let exs ← discover root
  let target ← match name with
    | some n => match findByName exs n with
      | some e => pure e
      | none => throw <| IO.userError s!"no exercise named `{n}`"
    | none => match ← nextPending root exs with
      | some (e, _) => pure e
      | none => throw <| IO.userError "every exercise already passes"
  say bold s!"{target.chapter}/{target.name}"
  showHint target
  return 0

def cmdSolution (root : System.FilePath) (name : String) : IO UInt32 := do
  let exs ← discover root
  match findByName exs name with
  | none => throw <| IO.userError s!"no exercise named `{name}`"
  | some e =>
    let sol := root / e.solution
    if ← sol.pathExists then
      say bold s!"Solution for {e.chapter}/{e.name} ({sol}):"
      IO.println (← IO.FS.readFile sol)
      return 0
    else
      say yellow s!"no solution file at {sol}"
      return 1

def cmdReset (root : System.FilePath) (name : String) : IO UInt32 := do
  let exs ← discover root
  match findByName exs name with
  | none => throw <| IO.userError s!"no exercise named `{name}`"
  | some e =>
    let orig := root / ".templates" / e.chapter / (e.name ++ ".lean")
    if !(← orig.pathExists) then
      throw <| IO.userError s!"no pristine copy at {orig}"
    IO.FS.writeFile e.path (← IO.FS.readFile orig)
    say yellow s!"reset {e.chapter}/{e.name} to its original state"
    return 0

def cmdWatch (root : System.FilePath) : IO UInt32 := do
  say bold "Watching exercises. Save a file to re-check it; Ctrl-C to quit."
  let mut last := ""
  repeat
    let exs ← discover root
    let mut key := ""
    for e in exs do
      key := key ++ (← stamp e.path)
    if key != last then
      last := key
      clearScreen
      let _ ← cmdVerify root
      IO.println ""
      say dim "watching..."
    IO.sleep 700
  return 0

def usage : String :=
"leanlings - small Lean 4 exercises, in the spirit of rustlings

USAGE:
    leanlings [COMMAND]

COMMANDS:
    verify              Check exercises in order, stopping at the first unsolved one (default)
    watch               Same as verify, but re-runs every time you save a file
    run [NAME]          Check a single exercise (defaults to the next unsolved one)
    hint [NAME]         Print the hint for an exercise
    list                Show every exercise and its status
    solution NAME       Print the reference solution
    reset NAME          Restore an exercise to its original, unsolved state
    help                Show this message

Fix an exercise and save: as soon as it compiles cleanly it is marked done and
leanlings moves you on to the next one."

def main (args : List String) : IO UInt32 := do
  let root ← findRoot
  match args with
  | [] | ["verify"]         => cmdVerify root
  | ["watch"]               => cmdWatch root
  | ["run"]                 => cmdRun root none
  | ["run", n]              => cmdRun root (some n)
  | ["hint"]                => cmdHint root none
  | ["hint", n]             => cmdHint root (some n)
  | ["list"]                => cmdList root
  | ["solution", n]         => cmdSolution root n
  | ["reset", n]            => cmdReset root n
  | ["help"] | ["--help"] | ["-h"] => do IO.println usage; return 0
  | _ => do IO.println usage; return 2

end Leanlings
