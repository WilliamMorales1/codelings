# HINT
# 1. Predict: if IO.write("a") and IO.puts("b") run back to back, what exactly appears on screen, and where does the cursor end up? Try both orders in IEx.
# 2. One of the two IO printing functions adds a newline and the other does not. The first placeholder needs the one that leaves the line open for IO.puts("OK") to finish.
# 3. For the second placeholder you want the IO function that prints a value in its inspected form, accepts a label: option, and returns the value unchanged so the pipe keeps flowing.

%{expected_output: "Status: OK\ntotal: 6\n"}
