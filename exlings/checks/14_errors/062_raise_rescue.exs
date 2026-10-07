# HINT
# 1. Run raise ArgumentError, "oops" in IEx and look at what is printed. What kind of struct is an exception, and how would you match only that kind?
# 2. rescue filters by exception type with e in ModuleName. Which module does Parser.parse_positive/1 raise for bad input?
# 3. The clause is e in ArgumentError -> "Rescued: #{e.message}".

%{expected_output: "Parsed: 42\nRescued: expected a positive number, got: -5\n"}
