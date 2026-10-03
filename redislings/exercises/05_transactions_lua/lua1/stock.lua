-- lua1 — EVAL: an atomic check-and-decrement
--
-- Learn: a Lua script sent with EVAL runs on the server as one atomic
-- step: no other command runs in the middle, so "check, then write" is
-- safe without WATCH. Inside, redis.call() runs commands, KEYS holds the
-- key names and ARGV the other arguments. Replies come back as Lua
-- values: strings stay strings, and a missing key comes back as false.
--
-- Task: take one item from the stock counter KEYS[1]. If there is stock,
-- decrement it and return the new amount; if it's 0 or the key doesn't
-- exist, return -1 and change nothing. The check runs it with
--   redis-cli --eval stock.lua stock:widget
-- and fires 20 of them at once at a stock of 5.
--

local stock = redis.call('GET', KEYS[1])
if stock > 0 then
  return redis.call('DECR', KEYS[1])
end
return -1
