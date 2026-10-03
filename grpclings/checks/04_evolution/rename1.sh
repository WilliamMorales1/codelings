#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# Put `string user_name = 2 [deprecated = true];` back and add
# `string display_name = 4;`. Generated Go code then marks GetUserName with
# a "Deprecated:" comment, so linters flag every remaining caller.
source "$GRPCLINGS_LIB"
need_file buf.yaml released/acme/accounts/v1/account.proto
[[ -z "$(diff -q released/acme/accounts/v1/account.proto "$GRPCLINGS_ROOT/.templates/$EXERCISE_ID/released/acme/accounts/v1/account.proto" 2>&1)" ]] ||
  fail "released/ is the last release and must not be edited"
expect_buf_breaking released
expect_buf_lint
buf_image
a=$(msg_json acme.accounts.v1.Account)
expect_eq "$(jq -r '.field[] | select(.name == "display_name") | .number' <<<"$a")" "4" "display_name is field 4"
expect_eq "$(jq -r '.field[] | select(.name == "user_name") | "\(.number) \(.options.deprecated // false)"' <<<"$a")" "2 true" "user_name is still field 2, deprecated"
