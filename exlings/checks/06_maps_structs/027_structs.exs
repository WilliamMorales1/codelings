# HINT
# 1. Re-read the note about scripts in the comments. Why can %Point{} only be built from inside the Point module here?
# 2. defstruct takes a keyword list of fields and their defaults. What would defstruct x: 0, y: 0 give you?
# 3. new/2 should return %Point{x: x, y: y}, and the call site is Point.new(10, 20).

%{expected_output: "Point coordinates: x=10, y=20\n"}
