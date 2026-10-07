# HINT
# 1. Predict: before any defimpl exists, what error does "Price: #{price}" raise in IEx, and which protocol does the error message name?
# 2. The defimpl needs its target after for:. Which module defines the struct being pattern-matched in to_string/1?
# 3. Inside the body, interpolation already works on amount (integer) and currency (atom): return "#{amount} #{currency}".

%{expected_output: "Price: 99 USD\nTotal: 99 USD\n"}
