# HINT
# 1. Enum.filter keeps elements where the function returns a truthy value. How do you test that a number is even? Try rem/2 in IEx.
# 2. Use fn n -> rem(n, 2) == 0 end and fn w -> String.length(w) > 3 end.

%{expected_output: "Evens: [2, 4, 6, 8]\nLong words: [\"elixir\", \"erlang\"]\n"}
