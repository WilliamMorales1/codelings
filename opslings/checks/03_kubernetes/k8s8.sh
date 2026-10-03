#!/usr/bin/env bash
# REQUIRES: kubeconform yq
# HINT
# Deployments live in apiGroups: ["apps"], and "*" grants far more than
# asked: list the four verbs. The RoleBinding must sit in namespace `ci`,
# refer to `kind: Role` (it is not a ClusterRole), and name the subject as a
# ServiceAccount:
#   subjects:
#     - kind: ServiceAccount
#       name: deployer
#       namespace: ci
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file rbac.yaml
kubeval rbac.yaml
role='select(.kind == "Role")'
rb='select(.kind == "RoleBinding")'
expect_yq rbac.yaml "$role | .metadata.namespace" "ci" "Role namespace"
rule() {
  yq eval "$role | .rules[] | select(.resources[] == \"$1\") | (.apiGroups | join(\",\")) + \" \" + (.verbs | sort | join(\",\"))" rbac.yaml
}
expect_eq "$(rule pods)" " get,list,watch" "pods rule (core group)"
expect_eq "$(rule deployments)" "apps get,list,patch,update" "deployments rule"
expect_yq rbac.yaml "$rb | .metadata.namespace" "ci" "RoleBinding namespace"
expect_yq rbac.yaml "$rb | .roleRef.kind + \"/\" + .roleRef.name" "Role/$(yq eval "$role | .metadata.name" rbac.yaml)" "roleRef points at the Role"
expect_yq rbac.yaml "$rb | .subjects[0] | .kind + \" \" + .namespace + \"/\" + .name" "ServiceAccount ci/deployer" "subject is the deployer ServiceAccount"
expect_yq rbac.yaml "$rb | .subjects | length" "1" "exactly one subject"
