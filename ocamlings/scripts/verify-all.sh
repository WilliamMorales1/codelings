#!/usr/bin/env bash
# Course maintenance: every solution passes its check, every untouched exercise fails it.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
if ! command -v ocaml >/dev/null; then
    echo "SKIPPED: needs ocaml"
    exit 0
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
fail=0
for side in solutions .templates; do
    rm -rf "${work:?}"/* "$work"/.ocamlings-progress
    cp -r ocamlings checks "$work"/
    cp -r "$side" "$work"/exercises
    for check in $(find checks -mindepth 2 -name '*.ml' | sort -V); do
        id=${check#checks/}
        id=${id%.ml}
        out=$(cd "$work" && NO_COLOR=1 ./ocamlings run "$id" 2>&1)
        rc=$?
        if [[ $side == solutions && $rc -ne 0 ]]; then
            echo "FAIL $id: solution does not pass"
            printf '%s\n' "$out" | head -n 20
            fail=1
        elif [[ $side == .templates && $rc -eq 0 ]]; then
            echo "FAIL $id: untouched exercise already passes"
            fail=1
        else
            echo "ok   $id ($side)"
        fi
    done
done
((fail == 0)) && echo "ALL GOOD"
exit $fail
