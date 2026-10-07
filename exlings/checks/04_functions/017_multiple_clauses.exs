# HINT
# 1. Run the file and read the FunctionClauseError. Which of the two calls has no matching clause?
# 2. Mirror the existing clause: match {:error, reason} and interpolate reason into the string, like the {:ok, value} clause does.
# 3. def handle_result({:error, reason}), do: "Error: #{reason}"

%{expected_output: "Success: 42\nError: failed\n"}
