#!/bin/sh
# Moves every file from inbox/ to done/.
cd "$(dirname "$0")" || exit 1
mkdir -p done
echo "processing inbox"
for f in inbox/*; do
    [ -e "$f" ] || continue
    mv "$f" done/ && echo "processed ${f#inbox/}"
done
