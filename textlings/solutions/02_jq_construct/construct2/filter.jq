# construct2: building arrays, map and add
#
# `[ f ]` collects every output of f into one array. `map(f)` is
# `[.[] | f]`. `add` sums an array of numbers (or joins strings / merges
# objects). Parenthesise a pipe that is an object value: {x: (f | g)}.
#
# repos.json is `gh api orgs/acme/repos`. Print one object with the number
# of repos, an array of their names, and their total stars:
#     {"repos": 6, "names": ["api", ...], "stars": 1234}

{
  repos: length,
  names: map(.name),
  stars: (map(.stargazers_count) | add)
}
