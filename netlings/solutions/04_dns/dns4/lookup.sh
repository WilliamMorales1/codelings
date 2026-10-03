# dns4: asking DNS directly with dig

dig +short lab.test MX
dig +short _verify.lab.test TXT
dig +short -x 10.53.0.80
dig +noall +answer api.lab.test A | awk '{print $2}'
