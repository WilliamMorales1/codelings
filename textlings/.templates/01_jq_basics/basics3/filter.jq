# basics3: pipes and the comma
#
# `a | b` feeds every output of a into b. `a, b` emits the outputs of a,
# then those of b, both from the same input. The comma binds tighter than
# the pipe: `.[] | .x, .y` means `.[] | (.x, .y)`.
#
# pulls.json is `gh api repos/acme/widget/pulls`. For every pull request,
# in order, print its number and then its branch name (head.ref), so the
# output alternates: number, branch, number, branch, ...
#

.[].number, .[].head.ref
