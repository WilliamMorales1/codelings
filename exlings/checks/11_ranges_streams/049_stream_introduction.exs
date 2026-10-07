# HINT
# 1. Compare Enum.map(1..10, fn n -> n * 2 end) with Stream.map(1..10, fn n -> n * 2 end) in IEx. What does each one return?
# 2. A stream does nothing until an Enum function consumes it. Enum.take(stream, 3) pulls just three values.

%{expected_output: "First three: [2, 4, 6]\n"}
