# HINT
# 1. Try <<104, 101, 108, 108, 111>> in IEx and compare it with "hello". What does that tell you about strings?
# 2. Match against greeting itself. The rest::binary segment collects every byte after the first two.

%{expected_output: "First byte: 104\nSecond byte: 101\nRest: llo\n"}
