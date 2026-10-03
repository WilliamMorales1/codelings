# advanced4: foreach
#
# `reduce` gives only the final state. `foreach SOURCE as $x (INIT;
# UPDATE; EXTRACT)` emits EXTRACT after every step, so you can print a
# running total. Floats add up with rounding noise: round to cents with
# (. * 100 | round) / 100.
#
# costs.json is a daily cost export. For each day print the date, that
# day's cost and the running total so far:
#     2026-09-01 57.32 57.32
#     2026-09-02 21.9 79.22
#

reduce .[] as $d (0; . + $d.usd)
