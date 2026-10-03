# advanced2: unique and join
#
# `unique` sorts an array and drops duplicates; `unique_by(f)` keeps one
# element per value of f. `join(", ")` glues an array of strings.
#
# package-lock.json is an npm v3 lockfile: .packages maps install paths
# (node_modules/a/node_modules/b) to {version, ...}. The same package can
# be installed more than once. List every package that is installed in
# more than one *distinct* version, as  name: v1, v2  (versions
# de-duplicated and sorted, packages sorted by name).

.packages
| to_entries
| map(select(.key != "") | {name: (.key | sub(".*node_modules/"; "")), version: .value.version})
| group_by(.name)
| map({name: .[0].name, versions: (map(.version) | unique)})
| map(select(.versions | length > 1))
| .[] | "\(.name): \(.versions | join(", "))"
