# http5: looking at a TLS certificate with openssl s_client
# s_client reads stdin until EOF; </dev/null lets it finish after the handshake.

openssl s_client -connect 10.0.0.2:443 -servername secure.lab.test </dev/null 2>/dev/null |
  openssl x509 -noout -subject -issuer
