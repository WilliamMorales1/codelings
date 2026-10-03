# advanced5: -n and inputs (streams of JSON)
#
# `journalctl -o json` prints one JSON object per line, not an array.
# jq runs your filter once per object, so there is nothing to reduce
# over. With -n (--null-input) jq runs the filter once, on null, and
# `inputs` yields every object of the input stream.
#
# journal.json is `journalctl -o json --since today`. Count the entries at
# warning level or worse (PRIORITY is a *string*; 4 = warning, 3 = err,
# 2 = crit) per _SYSTEMD_UNIT, as one object:
#     {"nginx.service": 3, "sshd.service": 2, ...}
#

# TODO: this runs once per journal entry. Run it once (flags), read entries with `inputs`.
reduce (. | select(.PRIORITY | tonumber <= 4)) as $e ({}; .[$e._SYSTEMD_UNIT] += 1)
