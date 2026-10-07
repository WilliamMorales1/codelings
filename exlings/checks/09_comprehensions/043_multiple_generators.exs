# HINT
# 1. Try for x <- [1, 2], y <- [:a, :b], do: {x, y} in IEx. How many pairs come out, and why that many?
# 2. The second generator looks like the first one: y <- ys. Each x is then paired with every y.

%{expected_output: "Pairs: [{1, :a}, {1, :b}, {2, :a}, {2, :b}, {3, :a}, {3, :b}]\n"}
