# construct9: pick (jq 1.7+)
#
# `pick(pathexps)` keeps only the given paths and preserves their nesting:
# `pick(.user.login)` gives {"user": {"login": ..}}. It is new in jq 1.7,
# so older distros (Debian 12 ships 1.6) do not have it; there you would
# build the nested object by hand.
#
# pulls.json is `gh api repos/acme/widget/pulls`. Slim it down for a report:
# for each PR keep only number, draft, user.login and head.ref, with the
# same nesting as the original. Output one compact line per PR.

.[] | pick(.number, .draft, .user.login, .head.ref)
