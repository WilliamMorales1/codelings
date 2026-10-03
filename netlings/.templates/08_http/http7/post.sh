# http7: sending JSON
#
# `curl -d DATA` makes a POST with DATA as the body, and labels it
# `Content-Type: application/x-www-form-urlencoded` (what an HTML form sends),
# whatever DATA looks like. APIs that want JSON reject that with
# 415 Unsupported Media Type. Either set the header yourself, or use
# `--json DATA` (curl 7.82+), which sets Content-Type and Accept to JSON.
#
# b (10.0.0.2) has POST /api/items, which wants a JSON body {"name": "..."}
# and answers 201 with {"id": 42, "name": ...}. The check runs this in a and
# expects that answer, for an item named "router".

curl -s -X POST -d '{"name": "router"}' http://10.0.0.2/api/items
