with import <nixpkgs> {};

rec {
  employees = [ { name = "Alice"; role = "Engineer"; }
                { name = "Bob"; role = "Manager"; }
                { name = "Charlie"; role = "Designer"; }
                { name = "David"; role = "Tester"; } ];

  findByRole = role: lib.filter (e: e.role == role) employees;
  findByName = name: lib.filter (e: e.name == name) employees;

  output = {
    alice = findByName "Alice";
    designer = findByRole "Designer";
  };
}
