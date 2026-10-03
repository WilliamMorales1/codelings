# http4: status codes and redirects

curl -sL -o /dev/null -w '%{http_code} %{url_effective}\n%{num_redirects}\n' http://10.0.0.2/old
