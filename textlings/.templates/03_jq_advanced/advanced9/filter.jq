# advanced9: walk
#
# `walk(f)` applies f to every value in the document, bottom-up, and
# rebuilds it. A classic: drop every null field at every depth, which
# makes API responses much shorter to read.
#
# repo.json is `gh api repos/acme/widget`. Remove every key whose value is
# null, at any depth.
#

with_entries(select(.value != null))
