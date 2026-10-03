with import <nixpkgs> {};

rec {
  employees = [ { name = "Alice"; role = "Engineer"; }
                { name = "Bob"; role = "Manager"; }
                { name = "Charlie"; role = "Designer"; }
                { name = "David"; role = "Tester"; }
                { name = "Evelyn"; role = "Engineer"; }
                { name = "Frank"; role = "Designer"; }
                { name = "Greta"; role = "Tester"; } ];

  roles = {
    Engineer = 90000;
    Manager = 110000;
    Designer = 85000;
    Tester = 75000;
  };

  findByRole = role: lib.filter (e: e.role == role) employees;

  processPayroll = role: yearlyPayout: rec {
    payout = yearlyPayout / 12.0;
    recipients = map (e: e.name) (findByRole role);
    totalPayout = payout * lib.length recipients;
  };

  output = {
    payroll = lib.mapAttrs processPayroll roles;
  };
}
