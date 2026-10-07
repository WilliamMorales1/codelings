# HINT
# 1. Look at {:ok, value}: which part varies between calls? That part should be a variable in the pattern.
# 2. The patterns are {:ok, value} and {:error, reason}.

%{expected_output: "Success: data loaded\nError: connection failed\n"}
