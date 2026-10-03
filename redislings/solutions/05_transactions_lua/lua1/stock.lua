-- lua1 — EVAL: an atomic check-and-decrement

local stock = tonumber(redis.call('GET', KEYS[1]) or 0)
if stock > 0 then
  return redis.call('DECR', KEYS[1])
end
return -1
