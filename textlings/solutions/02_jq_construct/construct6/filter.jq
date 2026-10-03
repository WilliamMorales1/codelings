# construct6: with_entries
#
# `with_entries(f)` is `to_entries | map(f) | from_entries`: edit the keys
# and values of an object and get an object back. `map` alone on an
# object throws the keys away.
#
# package.json is an npm manifest. Print its dependencies object with the
# range operators ^ and ~ stripped from every version:
#     {"react": "19.1.1", "zod": "4.1.5", ...}

.dependencies | with_entries(.value |= sub("^[\\^~]"; ""))
