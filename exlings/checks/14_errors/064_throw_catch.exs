# HINT
# 1. Predict: what does the try expression return if the loop finishes without throwing anything? And what does it return when a throw happens mid-loop?
# 2. catch pattern-matches on the thrown value. Read the existing catch clause and throw something with exactly that shape.
# 3. The clause expects {:found, n}, so throw that tuple: throw({:found, n}).

%{expected_output: "Search result: 7\n"}
