# HINT
# 1. Predict: Emitter.emit receives a module atom like QueryEncoder in its encoder variable. Once the module compiles, what does QueryEncoder.encode([a: 1]) return? Try calling it directly in IEx.
# 2. When a variable holds a module name, you can call a function on it with the usual dot syntax: variable.function(args). The @callback typespec describes a function from a list of tuples to a String.t().
# 3. emit/2 is a single line: encoder.encode(pairs).

%{expected_output: "Query: name=ana&lang=elixir\nCSV:   ana,elixir\n"}
