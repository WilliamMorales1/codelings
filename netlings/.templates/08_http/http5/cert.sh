# http5: looking at a TLS certificate with openssl s_client
#
# `openssl s_client -connect HOST:PORT` does a TLS handshake and then sits
# there as an interactive client (you could type an HTTP request). Piping its
# output into `openssl x509 -noout -subject -issuer -dates -ext subjectAltName`
# decodes the server's certificate. `-servername NAME` sends SNI, which
# servers with several certificates need to pick the right one.
#
# b (10.0.0.2) serves HTTPS on 443 for secure.lab.test. The check runs this
# in a and expects two lines like openssl prints them:
#     subject=O=netlings, CN=secure.lab.test
#     issuer=O=netlings, CN=netlings test CA
#
# Your task: this hangs forever (the check gives up after 5 seconds). Why
# would s_client wait? What is it reading from?

openssl s_client -connect 10.0.0.2:443 -servername secure.lab.test 2>/dev/null |
  openssl x509 -noout -subject -issuer
