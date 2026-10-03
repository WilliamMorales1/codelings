rec {
  mkGreeting = greeting: towards: "${greeting} ${towards}";

  output = {
    message = mkGreeting "Hello" "Nixlings";
  };
}
