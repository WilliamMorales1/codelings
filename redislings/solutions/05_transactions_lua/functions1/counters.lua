#!lua name=counters
-- functions1 — FUNCTION LOAD and FCALL / FCALL_RO

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
redis.register_function{
  function_name = 'get_count',
  callback = get_count,
  flags = { 'no-writes' },
}
