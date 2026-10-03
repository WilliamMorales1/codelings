package intro1

// Greet builds the message the check expects: "Hello, <name>!".
func Greet(name string) *Greeting {
	return &Greeting{Text: "Hello, " + name + "!"}
}
