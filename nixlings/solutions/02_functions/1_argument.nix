rec {
  makeMessage = a: b: "${a "de"} ${b "Nixling"}";

  mkGreeting = lang: { "de" = "Hallo"; "en" = "Hello"; }."${lang}";

  pluralize = noun: "${noun}s";

  output = {
    message = (makeMessage mkGreeting pluralize);
  };
}
