# HINT
# 1. Investigate: in IEx, assign module = String and call module.upcase("hi"). What does that tell you about what a module name is, and what you can do with it?
# 2. broadcast/3 receives provider as a plain variable holding a module. The call syntax provider.deliver(recipient, message) works exactly like Email.deliver/2.
# 3. Email returns "[email] to #{recipient}: #{message}", Sms the same with [sms], and broadcast's body is provider.deliver(recipient, message).

%{expected_output: "[email] to alice@example.com: build succeeded\n[sms] to alice@example.com: build succeeded\n"}
