# HINT
# 1. Investigate: after `alias Fruit.Store.Inventory`, what name does Elixir give the module? Try calling count/1 on it in IEx using only part of the full name.
# 2. alias A.B.C makes the LAST segment available as the module name. With `as: Inv`, the name is exactly the one you chose.

%{expected_output: "Items: 3\nFirst: apple\n"}
