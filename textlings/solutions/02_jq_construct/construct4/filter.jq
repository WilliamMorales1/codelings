# construct4: to_entries and string interpolation
#
# `to_entries` turns {"a": 1} into [{"key": "a", "value": 1}], so you can
# iterate an object's keys and values together. Inside a string,
# "\(expr)" interpolates the result of expr.
#
# package.json is an npm manifest. Print every dependency as name@range,
# runtime dependencies first, then devDependencies with " (dev)" after
# them, in the order they appear in the file:
#     react@^19.1.1
#     ...
#     vite@^7.1.7 (dev)

(.dependencies | to_entries[] | "\(.key)@\(.value)"),
(.devDependencies | to_entries[] | "\(.key)@\(.value) (dev)")
