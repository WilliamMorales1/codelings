# HINT
# 1. Predict: @title is set at the top of the module. Inside title/0, how do you think you read that value back? Look at how welcome/0 uses @title in its string.
# 2. A module attribute is read with @name anywhere in the module body, including inside functions. title/0 should return the attribute that holds "Star Runner".

%{expected_output: "Star Runner\n3\nWelcome to Star Runner! Lives: 3\n"}
