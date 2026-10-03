rec {
  makeMessage = a: (b: "${mkGreeting a} ${pluralize b}");

  mkGreeting = lang: { "de" = "Hallo"; "en" = "Hello"; }."${lang}";
  pluralize = noun: "${noun}s";

  output = {
    message = (makeMessage "de") "Nixling";
  };
}
