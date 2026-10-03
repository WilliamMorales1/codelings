with import <nixpkgs> {};

rec {
  employees = [ "Alice" "Bob" "Charlie" "David"];
  roles = ["Engineer" "Manager" "Designer" "Tester"];

  output = {
    list = map ({ fst, snd }: { name = fst; role = snd; }) (lib.zipLists employees roles);
  };
}
