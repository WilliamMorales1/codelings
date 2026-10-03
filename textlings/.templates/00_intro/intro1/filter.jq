# intro1: the ritual
#
# Every exercise is a directory with some input data and one program you
# write. This one is a jq filter that should print the "name" field of
# package.json, but it picks the wrong field.
#
# Try it yourself (from this directory):
#     jq -f filter.jq package.json
# and compare with expected.txt, which is what the check wants to see.
#
# The check also runs your program on a second, hidden input, so a filter
# that just prints the right answer as a constant will not pass. Once it
# passes, the exercise is done and textlings moves on.

.version
