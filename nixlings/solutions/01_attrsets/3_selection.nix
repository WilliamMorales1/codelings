rec {
  greetings = {
    "de" = "Hallo";
    "en" = "Hello";
    "eo" = "Saluton";
    "fr" = "Salut";
  };

  makeGreeting = lang: "${greetings.${lang}} Nixlings";

  output = {
    message = (makeGreeting "en");
  };
}
