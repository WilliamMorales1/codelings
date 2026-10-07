# HINT
# 1. Predict: in IEx, evaluate ~D[2026-08-15] == "2026-08-15". Why is it false? Then inspect ~D[2026-08-15] and note which struct it builds.
# 2. The date sigil is ~D with square brackets in YYYY-MM-DD format; the time sigil is ~T with HH:MM:SS.
# 3. Both answers are single sigil literals: the deadline uses ~D[...] with the date from the header comment, the alarm uses ~T[...].

%{expected_output: "Deadline: 2026-08-15\nCompare: :gt\nDays apart: 226\nAlarm at: 07:30:00\n"}
