# HINT
# 1. Predict: what does IO.puts(~S(a#{1 + 1}b)) print compared to IO.puts(~s(a#{1 + 1}b))? Try both in IEx before editing the exercise.
# 2. The first gap needs the lowercase sigil (interpolation on), the second its uppercase twin. For the word list, the element type comes from a single letter right after the closing delimiter.
# 3. The modifiers are s (strings, the default), a (atoms) and c (charlists). Which one produces [:alpha, :beta, :gamma]?

%{expected_output: "learning exlings is \"fun\"\nlearning \#{tool} is \"fun\"\nAtoms: [:alpha, :beta, :gamma]\n"}
