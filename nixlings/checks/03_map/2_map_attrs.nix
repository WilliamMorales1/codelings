# HINT
# `lib.mapAttrs processPayroll roles` calls processPayroll with each role name
# and its yearly figure. Divide by 12.0 (not 12) to get a float, list the
# names with findByRole, and multiply the monthly payout by how many there are.
ex:
  let p = ex.output.payroll;
  in
  builtins.attrNames p == [ "Designer" "Engineer" "Manager" "Tester" ]
  && p.Engineer.recipients == [ "Alice" "Evelyn" ]
  && p.Manager.recipients == [ "Bob" ]
  && p.Engineer.payout == 7500.0
  && p.Engineer.totalPayout == 15000.0
  && p.Tester.totalPayout == 12500.0
