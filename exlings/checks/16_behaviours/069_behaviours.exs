# HINT
# 1. Predict: remove the @impl true line from a working module (or try it in any project): does the code still run? What does the compiler say instead?
# 2. A callback looks like a typespec without a body: @callback name(args) :: return_type(). The adopting module names the behaviour module after @behaviour.
# 3. @callback area(struct()) :: float() in Shape, @behaviour Shape inside Square, @impl true above area/1, and the body is side * side.

%{expected_output: "Square area: 16.0\n"}
