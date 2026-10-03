# http4: status codes and redirects
#
# 2xx = fine, 3xx = look elsewhere (the Location header says where),
# 4xx = your fault, 5xx = the server's fault. 301/308 are permanent moves,
# 302/303/307 temporary. curl does NOT follow redirects unless you pass -L.
#
# `-w` prints facts about the transfer after it is done, e.g.
#     curl -s -o /dev/null -w '%{http_code} %{url_effective}\n' URL
# (-o /dev/null throws the body away). Health checks and scripts use this a lot.
#
# b (10.0.0.2) has moved a page: /old -> 301 -> /moved -> 302 -> /final.
# The check runs this in a and expects, on the first line, the final status code
# and the final URL, like
#     200 http://10.0.0.2/final
# Also print, on a second line, how many redirects were followed:
#     2
# (-w knows that one too: see `man curl`, search for num_redirects.)

curl -s -o /dev/null -w '%{http_code} %{url_effective}\n' http://10.0.0.2/old
