#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# Rename the service to UserService. Replace UserId with GetUserRequest and
# DeleteUserRequest (both `string user_id = 1;`), add
# `message GetUserResponse { User user = 1; }` and an empty
# `message DeleteUserResponse {}`, and drop the Empty import (buf lint also
# reports unused imports).
source "$GRPCLINGS_LIB"
need_file buf.yaml
expect_buf_lint
buf_image
expect_eq "$(img '[.file[] | select(.package == "acme.users.v1") | .service[]? | .name] | join(" ")')" "UserService" "service name"
expect_eq "$(img '[.file[].service[]? | select(.name == "UserService") | .method[] | "\(.name)(\(.inputType))\(.outputType)"] | join(" ")')" \
  "GetUser(.acme.users.v1.GetUserRequest).acme.users.v1.GetUserResponse DeleteUser(.acme.users.v1.DeleteUserRequest).acme.users.v1.DeleteUserResponse" "RPC signatures"
fields() { jq -r '[.field[]? | "\(.name)=\(.number)"] | join(" ")' <<<"$(msg_json "$1")"; }
expect_eq "$(fields acme.users.v1.GetUserRequest)" "user_id=1" "GetUserRequest fields"
expect_eq "$(fields acme.users.v1.DeleteUserRequest)" "user_id=1" "DeleteUserRequest fields"
expect_eq "$(fields acme.users.v1.GetUserResponse)" "user=1" "GetUserResponse fields"
expect_eq "$(fields acme.users.v1.DeleteUserResponse)" "" "DeleteUserResponse is empty"
expect_eq "$(fields acme.users.v1.User)" "user_id=1 email=2" "User is unchanged"
