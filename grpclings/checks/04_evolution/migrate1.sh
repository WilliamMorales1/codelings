#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# - Deleting fax is fine once its number and name can never come back:
#   `reserved 4;` and `reserved "fax";` inside Customer.
# - int32 -> int64 is binary-compatible, but JSON renders int64 as a string,
#   so JSON clients break: keep int32 (a new int64 field would be the way out).
# - Enum value names ARE the JSON encoding. Keep TIER_GOLD = 2 (if marketing
#   insists, `option allow_alias = true;` lets TIER_PREMIUM = 2 exist too).
# - website is a new field with a new number: always safe.
source "$GRPCLINGS_LIB"
need_file buf.yaml released/acme/crm/v1/customer.proto
[[ -z "$(diff -q released/acme/crm/v1/customer.proto "$GRPCLINGS_ROOT/.templates/$EXERCISE_ID/released/acme/crm/v1/customer.proto" 2>&1)" ]] ||
  fail "released/ is the last release and must not be edited (grpclings reset migrate1 restores it; save your proto first)"
expect_buf_breaking released
expect_buf_lint
buf_image
c=$(msg_json acme.crm.v1.Customer)
expect_eq "$(jq -r '.field[] | select(.name == "website") | .number' <<<"$c")" "7" "website is kept (field 7)"
expect_eq "$(jq -r '[.field[] | select(.name == "fax")] | length' <<<"$c")" "0" "fax is deleted"
expect_eq "$(jq -r '.reservedName // [] | index("fax") != null' <<<"$c")" "true" "the name fax is reserved"
