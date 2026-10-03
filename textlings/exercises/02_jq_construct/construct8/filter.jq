# construct8: @base64d and @sh
#
# Kubernetes stores Secret values base64-encoded. `@base64d` decodes a
# string; `@sh` quotes a string (or array of strings) so a POSIX shell
# reads it back verbatim, whatever spaces, $ or quotes it contains.
#
# secret.json is `kubectl get secret NAME -o json`. Print one line per key,
# ready for `eval` or a .env file:
#     export DB_HOST='pg-primary.prod.svc'
#

.data | to_entries[] | "export \(.key)=\(.value)"
