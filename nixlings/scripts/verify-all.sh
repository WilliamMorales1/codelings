#!/usr/bin/env bash
# Course maintenance: every solution passes its check, every untouched exercise fails it.
set -uo pipefail
cd "$(dirname "$0")/.."

fail=0
for check in $(find checks -name '*.nix' | sort -V); do
    id=${check#checks/}
    id=${id%.nix}
    sol=$(nix-instantiate --eval --strict --expr "(import ./$check) (import ./solutions/$id.nix)" 2>/dev/null)
    ex=$(nix-instantiate --eval --strict --expr "(import ./$check) (import ./exercises/$id.nix)" 2>/dev/null)
    if [[ "$sol" != true ]]; then
        echo "FAIL $id: solution does not pass"
        fail=1
    elif [[ "$ex" == true ]]; then
        echo "FAIL $id: untouched exercise already passes"
        fail=1
    else
        echo "ok   $id"
    fi
done
exit $fail
