#!/usr/bin/env bash
# Course maintenance: every solution passes its check, every untouched exercise fails it.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
for d in /usr/local/cuda/bin /opt/cuda/bin; do [[ -d "$d" ]] && PATH="$PATH:$d"; done
if ! command -v nvcc >/dev/null || ! nvidia-smi -L >/dev/null 2>&1; then
    echo "SKIPPED: needs nvcc and an NVIDIA GPU"
    exit 0
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
fail=0
for side in solutions .templates; do
    rm -rf "${work:?}"/* "$work"/.cudalings-progress "$work"/.build
    cp -r cudalings checks include "$work"/
    cp -r "$side" "$work"/exercises
    for check in $(find checks -name '*.check' | sort -V); do
        id=${check#checks/}
        id=${id%.check}
        out=$(cd "$work" && NO_COLOR=1 ./cudalings run "$id" 2>&1)
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
