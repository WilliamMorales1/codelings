## nimlings is a rustlings-style runner: it compiles and runs every file under exercises/ in order.

import std/[algorithm, hashes, os, osproc, strutils, tables, terminal, times]

const
  progressFile = ".nimlings-progress"
  usage = """nimlings - learn Nim by fixing tiny broken programs

USAGE:
    nimlings [verify]        Check exercises in order, stopping at the first unsolved one (default)
    nimlings watch           Same as verify, but re-checks every time you save a file
    nimlings run [NAME]      Check one exercise (defaults to the next unsolved one)
    nimlings hint [NAME]     Print the exercise's opening comment
    nimlings list            Show every exercise and its status
    nimlings solution NAME   Print the reference solution
    nimlings reset NAME      Restore an exercise to its original, unsolved state
    nimlings doctor          Show which external tools are installed and how to get the rest
    nimlings help            Show this message

With nimble, pass the verb after the binary name: `nimble run nimlings watch`.
NAME is a file name without .nim, such as exercise_02_assignments or just assignments.
An exercise is done as soon as it runs without failing; there is nothing to delete."""

type
  Exercise = object
    name, path: string

let color = getEnv("NO_COLOR") == "" and isatty(stdout)

proc paint(code, s: string): string =
  if color: "\e[" & code & "m" & s & "\e[0m" else: s

proc say(code, s: string) = echo paint(code, s)

proc fileLink(path: string): string =
  ## OSC 8 hyperlink; terminals without support just show the label.
  if color: "\e]8;;file://" & absolutePath(path) & "\e\\" & path & "\e]8;;\e\\" else: path

proc progressBar(done, total: int): string =
  let filled = if total > 0: 32 * done div total else: 0
  "Progress: [" & paint("32", '#'.repeat(filled) & '-'.repeat(32 - filled)) & "] " & $done & "/" & $total

proc indent(s: string) =
  for line in s.strip(leading = false).splitLines:
    echo "    ", line

proc findRoot(): string =
  var dir = getCurrentDir()
  while true:
    if dirExists(dir / "exercises") and fileExists(dir / "nimlings.nimble"):
      return dir
    let parent = dir.parentDir
    if parent == dir or parent == "":
      quit "could not find nimlings.nimble; run nimlings from inside the repository", 2
    dir = parent

proc discover(): seq[Exercise] =
  for path in walkFiles("exercises/*.nim"):
    result.add Exercise(name: path.splitFile.name, path: path)
  result.sort(proc (a, b: Exercise): int = cmp(a.name, b.name))

proc stamp(e: Exercise): string =
  let info = getFileInfo(e.path)
  $info.lastWriteTime.toUnixFloat & ":" & $info.size

## Passes are remembered with the file's stamp, so editing a solved exercise re-queues it.
proc loadProgress(): Table[string, string] =
  if fileExists(progressFile):
    for line in readFile(progressFile).splitLines:
      let parts = line.split('\t')
      if parts.len == 2: result[parts[0]] = parts[1]

proc done(e: Exercise): bool = loadProgress().getOrDefault(e.name) == e.stamp

proc record(e: Exercise, passed: bool) =
  var p = loadProgress()
  if passed: p[e.name] = e.stamp else: p.del(e.name)
  var s = ""
  for k, v in p: s.add k & "\t" & v & "\n"
  writeFile(progressFile, s)

proc check(e: Exercise): (bool, string) =
  let (output, code) = execCmdEx("nim r --hints:off --verbosity:0 " & quoteShell(e.path))
  e.record(code == 0)
  (code == 0, output)

proc find(exs: seq[Exercise], needle: string): Exercise =
  let n = needle.strip(chars = {'/'}).replace("exercises/", "").replace(".nim", "")
  for e in exs:
    if e.name == n or e.name.endsWith("_" & n):
      return e
  say "31", "no exercise named `" & needle & "` (try `nimlings list`)"
  quit 2

proc report(e: Exercise, ok: bool, output: string): bool =
  if not ok:
    say "31", "x " & e.name & " fails."
    echo "  File: ", fileLink(e.path)
    indent output
    echo "\n  Stuck? `nimlings hint ", e.name, "`"
    return false
  say "32", "v " & e.name & " passes!"
  indent output
  true

proc verify(exs: seq[Exercise]): int =
  for i, e in exs:
    if e.done: continue
    let (ok, output) = e.check
    if not ok:
      echo progressBar(i, exs.len), "\n"
      discard report(e, ok, output)
      return 1
  echo progressBar(exs.len, exs.len)
  say "32", "All " & $exs.len & " exercises complete!"
  0

proc stamp(exs: seq[Exercise]): Hash =
  for e in exs:
    let info = getFileInfo(e.path)
    result = result !& hash(e.path) !& hash(info.lastWriteTime.toUnixFloat) !& hash(info.size)
  result = !$result

proc watch() =
  var last: Hash
  while true:
    let exs = discover()
    let now = exs.stamp
    if now != last:
      last = now
      if color: stdout.write "\e[2J\e[H"
      discard verify(exs)
      say "2", "\nwatching... (Ctrl-C to quit)"
    sleep 700

proc next(exs: seq[Exercise]): Exercise =
  for e in exs:
    if not e.done and not e.check[0]:
      return e
  say "32", "Every exercise passes."
  quit 0

proc hint(e: Exercise) =
  ## The opening comment block is the task description.
  say "1", e.name
  say "36", "Hint:"
  for line in readFile(e.path).splitLines:
    if not line.startsWith("#") and line.strip != "": break
    echo "    ", line.strip(trailing = false, chars = {'#'})
  echo "  File: ", fileLink(e.path)

proc list(exs: seq[Exercise]) =
  var done = 0
  for e in exs:
    let label = if e.done: paint("32", "DONE   ") else: paint("33", "PENDING")
    if e.done: inc done
    echo label, "  ", e.name.alignLeft(32), " ", fileLink(e.path)
  echo "\n", progressBar(done, exs.len)

proc copyFrom(src: string, e: Exercise, what: string): int =
  if not fileExists(src):
    say "31", "no " & what & " at " & src
    return 1
  copyFile(src, e.path)
  say "33", "reset " & e.name & " to its original state"
  0

proc doctor(): int =
  for (tool, install) in [("nim", "install nim (or choosenim: https://github.com/nim-lang/choosenim)"), ("nimble", "install nimble (ships with nim on most systems)")]:
    let path = findExe(tool)
    if path == "":
      echo paint("31", "missing"), " ", tool.alignLeft(7), " ", install
      result = 1
    else:
      echo paint("32", "ok     "), " ", tool.alignLeft(7), " ", path
  echo ""
  if result == 0: say "32", "Everything is installed."

when isMainModule:
  let args = commandLineParams()
  let cmd = if args.len > 0: args[0] else: "verify"
  let arg = if args.len > 1: args[1] else: ""
  if cmd in ["help", "-h", "--help"]:
    echo usage
    quit 0
  if cmd == "doctor":
    quit doctor()
  setCurrentDir findRoot()
  let exs = discover()
  case cmd
  of "verify": quit verify(exs)
  of "watch": watch()
  of "run":
    let e = if arg == "": exs.next else: exs.find(arg)
    let (ok, output) = e.check
    quit(if report(e, ok, output): 0 else: 1)
  of "hint": hint(if arg == "": exs.next else: exs.find(arg))
  of "list": list(exs)
  of "solution":
    let e = exs.find(arg)
    let src = "solutions" / e.path.extractFilename
    if not fileExists(src):
      say "33", "no solution at " & src
      quit 1
    say "1", "Solution for " & e.name & ":"
    echo readFile(src)
  of "reset":
    if arg == "":
      say "31", "which exercise? (try `nimlings list`)"
      quit 2
    let e = exs.find(arg)
    quit copyFrom(".templates" / e.path.extractFilename, e, "pristine copy")
  else:
    echo usage
    quit 2
