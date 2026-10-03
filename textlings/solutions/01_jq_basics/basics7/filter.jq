# basics7: indexes, slices and length
#
# `.[0]` is the first element, `.[-1]` the last, `.[2:4]` a slice, and
# `length` counts an array (or the keys of an object, or a string's
# characters).
#
# releases.json is `gh api repos/acme/widget/releases`, newest first.
# Print, in this order: the newest tag, the number of releases, and the
# oldest tag. It must work for any number of releases.

.[0].tag_name,
length,
.[-1].tag_name
