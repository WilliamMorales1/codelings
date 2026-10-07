# HINT
# 1. Predict: run Integer.parse("42") and Integer.parse("abc") in IEx. What extra piece of information does the tuple carry besides the value itself?
# 2. You can match the bad input directly in the function head: a clause like def divide(_, 0) runs only when the divisor is zero.
# 3. The second clause computes the result with div(a, b) and wraps it: {:ok, div(a, b)}.

%{expected_output: "10 / 2 = 5\nError: division by zero\n"}
