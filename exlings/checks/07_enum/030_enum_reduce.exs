# HINT
# 1. Enum.reduce threads an accumulator through fn element, acc -> new_acc end. For a sum, what should the new accumulator be?
# 2. Use fn n, acc -> n + acc end for the sum. For the product, what single operator changes?
# 3. Sum: fn n, acc -> n + acc end with initial 0. Product: fn n, acc -> n * acc end with initial 1. Why does the product start at 1?

%{expected_output: "Sum: 15\nProduct: 120\n"}
