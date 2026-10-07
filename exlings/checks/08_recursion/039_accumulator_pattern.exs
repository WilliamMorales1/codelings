# HINT
# 1. Compare with exercise 037: there the sum was built while returning from the calls. Here acc carries the running total INTO the next call. What should the new acc be once head is seen?
# 2. The new accumulator combines the old acc with head using +. The recursive call keeps the shape do_sum(tail, new_acc).
# 3. The full call is do_sum(tail, acc + head). Why is returning acc the right move in the base case?

%{expected_output: "Sum: 15\n"}
