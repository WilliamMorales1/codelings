# http3: the Host header, and testing a name before DNS exists

curl -s --resolve shop.lab.test:80:10.0.0.2 http://shop.lab.test/
