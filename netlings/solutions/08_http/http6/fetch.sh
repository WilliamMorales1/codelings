# http6: trusting a private CA instead of -k

curl -s --cacert /run/netlings/ca.pem https://secure.lab.test/whoami
