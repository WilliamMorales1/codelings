# basics5: the optional operator ?
#
# `.[]` on null is an error ("Cannot iterate over null"), and so is `.foo`
# on a string. Appending ? (`.foo?`, `.[]?`) turns those errors into
# "no output" instead of stopping the whole run.
#
# events.json is `gh api repos/acme/widget/events`. Only PushEvents carry
# payload.commits. Print the message of every commit in every event.

.[] | .payload.commits[]? | .message
