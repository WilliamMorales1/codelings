#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# user reporter on >report-pass ~report:* -@all +@read
# user worker on >worker-pass ~queue:* -@all +@list
source "$REDISLINGS_ROOT/checks/lib.sh"

need_file users.acl
RDIR=$(scratch_dir)
grep -v '^#' users.acl | grep -v '^[[:space:]]*$' >"$RDIR/users.acl"
start_redis --aclfile "$RDIR/users.acl"
seed <<'SEED'
SET report:daily 42
SET secret:api-key hunter2
RPUSH queue:jobs a
SEED
expect_eq "$(r_as reporter report-pass GET report:daily)" "42" "reporter reads report:daily"
expect_match "$(r_as reporter report-pass GET secret:api-key)" "NOPERM" "reporter can't read secret:*"
expect_match "$(r_as reporter report-pass SET report:daily 0)" "NOPERM" "reporter can't write"
expect_eq "$(r_as worker worker-pass RPUSH queue:jobs b)" "2" "worker pushes to queue:jobs"
expect_eq "$(r_as worker worker-pass LPOP queue:jobs)" "a" "worker pops from queue:jobs"
expect_match "$(r_as worker worker-pass SET queue:jobs x)" "NOPERM" "worker can't run non-list commands"
expect_match "$(r_as worker worker-pass LPUSH report:daily x)" "NOPERM" "worker can't touch keys outside queue:*"
expect_match "$(r_as worker worker-pass FLUSHALL)" "NOPERM" "worker can't FLUSHALL"
expect_eq "$(r GET secret:api-key)" "hunter2" "nothing was damaged"
