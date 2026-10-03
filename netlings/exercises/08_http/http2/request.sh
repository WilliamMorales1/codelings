# http2: request headers
#
# Headers are "Name: value" lines sent before the body. curl sets a few itself
# (Host, User-Agent, Accept: */*); `-H 'Name: value'` adds or replaces one.
# APIs often insist on some: Accept to pick the response format, a token for
# authentication, a Content-Type for what you send.
#
# The check runs this inside a. b (10.0.0.2) serves GET /api/status, which
# answers {"status": "ok", ...} only to requests that
#   - accept JSON:         Accept: application/json   (else 406 Not Acceptable)
#   - carry the token:     X-Token: netlings          (else 401 Unauthorized)
#
# Your task: get the {"status": "ok"} answer. Add -v to see what you send.

curl -s -H "X-Token=netlings" http://10.0.0.2/api/status
