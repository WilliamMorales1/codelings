# HINT
# 1. Investigate: in IEx, run Enumerable.reduce([1, 2], {:cont, []}, fn x, acc -> {:cont, [x | acc]} end). What comes back, and what does that tell you about who handles {:cont, ...} for lists?
# 2. count/1 must return a tagged tuple {:ok, n}; the number of songs is just the length of the inner list. For reduce/3, delegate: call Enumerable.reduce on the inner list.
# 3. reduce's body is one line: Enumerable.reduce(songs, acc, fun). The list implementation handles halt and suspend for you.

%{expected_output: "Count: 3\nLoud: [\"SONG A\", \"SONG B\", \"SONG C\"]\nHas song B? true\n"}
