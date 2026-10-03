# journal3: journalctl -o json and jq

select((.PRIORITY | tonumber) <= 4) | "\(.PRIORITY) \(.MESSAGE)"
