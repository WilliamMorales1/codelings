# HINT
# `builtins.attrValues` turns an attrset into a list of its values (sorted by
# key), and `map (v: v * 2)` doubles each one. For myValues, `with values;`
# brings a, b and c into scope: `with values; [ a b c ]`.
ex: ex.output.message == "My favourite numbers are: [ 13 12 11 ] (26 24 22 are also fine)"
