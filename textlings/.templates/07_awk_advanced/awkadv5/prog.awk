# awkadv5: CSV with quoted fields: gawk FPAT  (gawk only)
#
# FS says what separates fields; gawk's FPAT says instead what a field
# looks like, which is what quoted CSV needs: a field is either a run of
# non-commas, or a double-quoted string that may contain commas.
# FPAT is a gawk extension. gawk 5.3+ and the one true awk (2nd edition)
# also have `--csv`, a command-line switch that does proper CSV parsing,
# doubled quotes included; this exercise sticks to FPAT so it works on
# any gawk since 4.0.
#
# Checked with plain `gawk -f prog.awk`.
#
# contacts.csv is a CRM export. For each contact print
#     name | company
# with the surrounding quotes removed, and "(none)" for an empty company.
#

BEGIN { FS = "," }
NR > 1 { print $2 " | " $4 }
