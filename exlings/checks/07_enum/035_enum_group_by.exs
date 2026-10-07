# HINT
# 1. Enum.group_by buckets elements under the key your function returns. What should the function return for an even number? For an odd one?
# 2. Use fn n -> if rem(n, 2) == 0, do: :even, else: :odd end.

%{expected_output: "Even: [2, 4, 6]\nOdd: [1, 3, 5]\n"}
