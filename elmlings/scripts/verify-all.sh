#!/usr/bin/env bash
# Course maintenance: every solution passes its check, every untouched exercise fails it.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
for tool in elm node; do
    if ! command -v "$tool" >/dev/null; then
        echo "SKIPPED: needs $tool"
        exit 0
    fi
done

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
fail=0
for side in solutions .templates; do
    rm -rf "${work:?}"/* "$work"/.elmlings-progress
    cp -r elmlings checks scripts "$work"/
    cp -r "$side" "$work"/exercises
    for check in $(find checks -mindepth 2 -path 'checks/[0-9]*' -name '*Check.elm' | sort -V); do
        id=${check#checks/}
        id=${id%Check.elm}
        out=$(cd "$work" && NO_COLOR=1 ./elmlings run "$id" 2>&1)
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
