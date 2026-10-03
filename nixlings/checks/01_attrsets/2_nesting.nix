# HINT
# `english` and `german` live inside `greetings`; from `output` you have to
# go through it (`greetings.english.text`). Inside `greetings`, `polite` on
# its own refers to english's own attribute: name german's instead.
ex: ex.output.message == "Hello Nixlings"
  && ex.greetings.english.polite == ex.greetings.german.polite
