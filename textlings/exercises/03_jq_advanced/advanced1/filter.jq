# advanced1: group_by and sort_by
#
# `group_by(f)` sorts an array by f and splits it into arrays of elements
# with equal f. `sort_by(f)` sorts by f; give it several keys,
# `sort_by(a, b)`, to break ties, and negate a number to sort descending.
#
# issues.json is `gh api repos/acme/widget/issues`. Print how many issues
# each author opened, most first, ties broken by login (A-Z):
#     4 octocat
#     3 hubot
#

group_by(.user.login)
| map({author: .user.login, issues: length})
| sort_by(.issues)                    # TODO: most first, then by author
| .[] | "\(.issues) \(.author)"
