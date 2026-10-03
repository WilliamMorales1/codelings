let
  values = { a = 13; b = 12; c = 11; };
  doubleValues = map (v: v * 2) (builtins.attrValues values);
in
rec {
  myValues = with values; [ a b c ];

  output = {
    message = "My favourite numbers are: [ ${toString myValues} ] (${toString doubleValues} are also fine)";
  };
}
