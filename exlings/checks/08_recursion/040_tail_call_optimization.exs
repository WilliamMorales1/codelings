# HINT
# 1. A call is in tail position when nothing happens after it returns. In 1 + count(tail), what is still waiting after the recursive call finishes?
# 2. do_count takes the tail and an accumulator that is one bigger. Write that call as the last expression of the clause.
# 3. The body is do_count(tail, acc + 1). Compare its memory use with the non-tail version in the comments.

%{expected_output: "Count: 1000\n"}
