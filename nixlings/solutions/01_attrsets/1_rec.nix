rec {
  greeting = "Hello";
  towards = "Nixlings";
  metadata.amount = 7;

  output = {
    message = "Saying '${greeting} ${towards}' ${builtins.toString metadata.amount} times";
  };
}
