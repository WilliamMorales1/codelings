# http6: trusting a private CA instead of -k
#
# HTTPS proves two things: the connection is encrypted AND you are talking to
# the real server, because its certificate is signed by a CA you trust. Your
# system trusts the public CAs; internal services often use a company CA.
# `curl -k` ("insecure") turns the second check off completely. It "works",
# and it would work just as well for an attacker in the middle.
# The right fix: tell curl which CA to trust, `--cacert FILE`.
#
# b serves https://secure.lab.test/ (the name is in /etc/hosts). Its CA
# certificate is /run/netlings/ca.pem. The check runs this in a and expects
# the /whoami JSON back, over a VERIFIED connection: no -k / --insecure.

curl -sk https://secure.lab.test/whoami
