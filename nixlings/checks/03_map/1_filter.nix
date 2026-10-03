# HINT
# `lib.filter (e: e.role == role) employees` keeps the matching entries.
ex:
  ex.output.alice == [ { name = "Alice"; role = "Engineer"; } ]
  && ex.output.designer == [ { name = "Charlie"; role = "Designer"; } ]
  && ex.findByRole "Tester" == [ { name = "David"; role = "Tester"; } ]
