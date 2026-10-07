# HINT
# 1. Predict: what happens in IEx if you interpolate a list directly, like "#{[1, 2]}"? Try it, then try inspect([1, 2]) instead.
# 2. String.Chars powers to_string/1 and interpolation; Inspect powers inspect/1. Integers have the first, lists and maps only have the second.
# 3. Fill in to_string(number) for the <>, and inspect(list) / inspect(user) inside the interpolations.

%{expected_output: "Number as string: 42\nList: [1, 2, 3]\nUser: %{name: \"exlings\", level: 15}\n"}
