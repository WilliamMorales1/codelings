# HINT
# 1. Enum.sort/2 takes a sorter function that returns true when the first element belongs before the second. For descending order, when does a belong before b?
# 2. Use fn a, b -> a >= b end, or the :desc shortcut.

%{expected_output: "Ascending: [1, 2, 3, 5, 8]\nDescending: [8, 5, 3, 2, 1]\n"}
