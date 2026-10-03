# advanced13: try/catch and error
#
# `try f catch g` runs g on the error message when f fails, instead of
# aborting. `error(msg)` raises your own error. `fromjson` parses a
# string as JSON (and fails on anything else). With -R, jq reads raw
# lines as strings instead of parsing JSON.
#
# app.log is a container's stdout: mostly JSON lines, but panics, access
# log lines and truncated JSON sneak in. Print, per line:
#   valid entry with a level:  LEVEL msg      (level upper-cased)
#   valid JSON, no level:      no level: <the line>
#   not JSON at all:           unparsed: <the line>
# Raise error("no level") yourself and tell it apart in the catch.

def entry: fromjson | if has("level") then . else error("no level") end;

. as $line
| try (entry | "\(.level | ascii_upcase) \(.msg)")
  catch (if . == "no level" then "no level: \($line)" else "unparsed: \($line)" end)
