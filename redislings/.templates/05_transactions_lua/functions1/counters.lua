#!lua name=counters
-- functions1 — FUNCTION LOAD and FCALL / FCALL_RO
--
-- Learn: EVAL ships the script with every call and the server forgets it.
-- Functions are loaded once as a named library (FUNCTION LOAD, first line
-- "#!lua name=<library>"), survive restarts and replication, and are
-- called by name: FCALL name numkeys key... arg...
-- A function that only reads can be declared with the 'no-writes' flag;
-- only such functions may be called with FCALL_RO, which also works on
-- read-only replicas.
--
-- Task: the library loads and incr_capped works, but
--   FCALL_RO get_count 1 counter:signups
-- is rejected. Register get_count as read-only. The check runs
--   redis-cli FUNCTION LOAD REPLACE "$(cat counters.lua)"
--

-- incr_capped(counter; cap): add 1, but never go above cap.
local function incr_capped(keys, args)
  local cap = tonumber(args[1])
  local n = redis.call('INCR', keys[1])
  if n > cap then
    redis.call('SET', keys[1], cap)
    return cap
  end
  return n
end

local function get_count(keys, args)
  return tonumber(redis.call('GET', keys[1]) or 0)
end

redis.register_function('incr_capped', incr_capped)
redis.register_function('get_count', get_count)
