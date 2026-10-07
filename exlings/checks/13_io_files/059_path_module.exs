# HINT
# 1. Investigate: in IEx, try Path.basename("data/reports/sales.csv") and Path.extname("data/reports/sales.csv"). Which one keeps the dot, and which one drops the directory?
# 2. The first placeholder takes a LIST of parts and joins them with the correct separator. The other two dissect the resulting string: one returns only the file name, the other only the extension.
# 3. Path.join accepts either separate arguments or a single list. Path.basename gives you "sales.csv"; the function that gives you ".csv" (dot included) is Path.extname.

%{expected_output: "Path: data/reports/sales.csv\nFile: sales.csv\nExtension: .csv\n"}
