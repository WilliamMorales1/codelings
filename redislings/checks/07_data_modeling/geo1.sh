#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# Swap each pair: GEOADD cities 2.3522 48.8566 paris -0.1278 51.5074 london ...
# (longitude = east/west = x, latitude = north/south = y)
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
run_file commands.redis
d=$(r GEODIST cities paris london km)
expect_between "${d%%.*}" 340 346 "paris-london is about 343 km"
expect_between "$(r GEODIST cities paris berlin km | cut -d. -f1)" 870 885 "paris-berlin is about 878 km"
expect_match "$OUT" '"34[0-6]\.[0-9]+"' "printed the paris-london distance"
expect_eq "$(tail -n 3 <<<"$OUT")" $'1) "paris"\n2) "brussels"\n3) "london"' "cities within 400 km of paris, nearest first"
