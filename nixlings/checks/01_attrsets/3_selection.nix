# HINT
# An attribute can be selected with a string held in a variable:
# `greetings.${lang}`. Then build "<greeting> Nixlings" around it.
ex:
  let
    m = ex.output.message;
    suffix = " Nixlings";
    n = builtins.stringLength m;
    k = builtins.stringLength suffix;
  in
  n > k && builtins.substring (n - k) k m == suffix
