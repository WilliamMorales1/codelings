# HINT
# 1. Investigate: in IEx, run File.write(Path.join(System.tmp_dir!(), "probe.txt"), "hi") and look at the return value. Then run File.read on the same path. What shapes do success results have?
# 2. The three placeholders are all functions in the File module: one writes content to a path, one reads a whole file into a string, one deletes a file. Match each placeholder to its job.
# 3. The patterns around the placeholders tell you the return shapes: `:ok = File.___(path, content)` for writing, `{:ok, content} = File.___(path)` for reading, and `:ok = File.___(path)` for removing.

%{expected_output: "Read back: Hello from a file!\nCleaned up!\n"}
