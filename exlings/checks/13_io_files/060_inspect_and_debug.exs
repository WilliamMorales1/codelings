# HINT
# 1. Predict: IO.inspect/2 returns something. If it returned nil, what would happen to Enum.sum() in this pipeline? Check in IEx what IO.inspect([1, 2]) actually returns.
# 2. The placeholder is a single pipe step that prints the list with the prefix "doubled: " and passes the list through untouched. It lives in the IO module and takes a label: option.
# 3. The step you need has the shape `|> IO.inspect(label: "doubled")`. Notice the expected output prints the inspect line BEFORE "Sum: 30", because the inspect fires while the pipeline runs.

%{expected_output: "doubled: [2, 4, 6, 8, 10]\nSum: 30\n"}
