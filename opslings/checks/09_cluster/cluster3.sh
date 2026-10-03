#!/usr/bin/env bash
# REQUIRES: docker kind kubectl yq
# HINT
# The logs say: fatal: GREETING is not set. Give the container the variable:
#           env:
#             - name: GREETING
#               value: hello from the cluster
# (same indentation as `command:`), then apply again.
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file deployment.yaml
c='.spec.template.spec.containers[0]'
expect_yq deployment.yaml "$c.env[] | select(.name == \"GREETING\") | .value" "hello from the cluster" "GREETING in deployment.yaml"
live_part
need_cluster
kc -n opslings get deploy greeter >/dev/null 2>&1 || fail "no Deployment greeter in namespace opslings: kubectl --context kind-opslings apply -f deployment.yaml"
wait_for 90 kc -n opslings rollout status deploy/greeter --timeout=1s || fail "deploy/greeter is not available; kubectl -n opslings logs deploy/greeter"
ok "deploy/greeter is available"
wait_for 20 bash -c "kubectl --context kind-opslings -n opslings logs deploy/greeter | grep -q 'hello from the cluster'" || fail "the greeter's logs do not say 'hello from the cluster'"
ok "logs say hello from the cluster"
