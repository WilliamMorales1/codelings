rec {
  greetings = rec {
    german = {
      text = "Hallo";
      polite = false;
    };
    english = {
      text = "Hello";
      polite = german.polite;
    };
  };
  towards = "Nixlings";
  output = {
    message = "${greetings.english.text} ${towards}";
  };
}
