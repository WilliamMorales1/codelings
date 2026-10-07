# HINT
# 1. Predict: in the first try, does the after block run before or after Result: 42 is printed? Walk the evaluation order in your head before running.
# 2. The after block's value is ignored, but its side effects still happen. The missing piece is just the cleanup message printed there.
# 3. Fill the placeholder with the string "Cleaning up".

%{expected_output: "Working...\nCleaning up\nResult: 42\nCleaning up again\nRescued: something broke\n"}
