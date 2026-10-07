# HINT
# 1. Predict: what is the difference between what File.read/1 returns and what File.stream!/1 returns? Call both on a file in IEx and compare.
# 2. The first placeholder opens the file as a lazy stream of lines (a File function whose name ends in `!`). The second is the Enum function that adds all numbers of a collection together.
# 3. Each streamed line still carries its trailing "\n", which is why String.trim/1 runs before String.to_integer/1. After that, the pipeline ends in a one-word Enum consumer that produces the total.

%{expected_output: "Total: 60\n"}
