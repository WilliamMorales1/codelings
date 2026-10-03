# construct7: @csv and @tsv
#
# `@csv` formats an array as one CSV row, quoting strings and doubling
# embedded quotes. `@tsv` does the same for tab-separated values. Both
# need -r, or you get the row back as a JSON string.
#
# issues.json is `gh api repos/acme/widget/issues`. Print a CSV file with
# a header row  number,title,author,state,comments  and then one row per
# issue (author is user.login). Titles can contain commas and quotes.

["number", "title", "author", "state", "comments"],
(.[] | [.number, .title, .user.login, .state, .comments])
| @csv
