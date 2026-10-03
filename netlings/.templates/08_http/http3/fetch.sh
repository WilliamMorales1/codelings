# http3: the Host header, and testing a name before DNS exists
#
# One IP address, many websites: the server looks at the Host header to decide
# which site you want (virtual hosting). For HTTPS the name also goes into the
# TLS handshake (SNI). So "curl the IP" is not the same as "curl the site".
#
# b (10.0.0.2) hosts shop.lab.test and blog.lab.test, but there is no DNS for
# them yet (the classic situation before a migration). curl has two ways to
# pretend:
#     curl --resolve shop.lab.test:80:10.0.0.2 http://shop.lab.test/
#     curl -H 'Host: shop.lab.test' http://10.0.0.2/
# (--resolve is better: it also gets TLS/SNI and cookies right.)
#
# The check runs this inside a. It must print the shop's front page
# ("welcome to the shop"), and must not edit /etc/hosts.

curl -s http://shop.lab.test/
