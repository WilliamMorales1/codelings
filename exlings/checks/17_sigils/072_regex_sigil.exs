# HINT
# 1. Predict: in IEx, run Regex.run(~r/[0-9]+/, "abc 123 def 456"). Which number comes back, and why that one instead of 456?
# 2. The digit shorthand is \d and the + quantifier means one or more. Named groups are written (?<name>pattern) and {n} repeats a class exactly n times.
# 3. The date pattern has the shape (?<year>D{4})-(?<month>D{2}) where D is the digit class.

%{expected_output: "Has digits: true\nOrder number: 42\nYear: 2026, Month: 08\n"}
