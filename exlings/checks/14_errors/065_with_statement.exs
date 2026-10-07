# HINT
# 1. Predict: when the left side of <- does not match the step's return value, where does that value go? Trace run.("abc") step by step.
# 2. Every step returns {:ok, value}; the last pattern must bind the doubled number to the name used in the do block. For else, look at which error atom Pipeline.positive/1 returns.
# 3. Bind with {:ok, doubled} <- and match {:error, :not_positive} in the else clause.

%{expected_output: "Result: 42\nError: not a number\nError: not positive\n"}
