-- lua2 — KEYS and ARGV: a safe lock release
--
-- Learn: a lock taken with SET key token NX PX ms must only be released
-- by its owner: if our lock expired and another worker took it, a blind
-- DEL would delete THEIR lock. "GET, compare, DEL" has to be atomic,
-- which is a job for a script. Pass every key the script touches in
-- KEYS (never build or hard-code key names inside it: Redis Cluster
-- routes the call by KEYS) and everything else in ARGV.
--
-- Task: delete the lock KEYS[1] only if its value equals ARGV[1]; return
-- 1 if you deleted it, 0 otherwise. The check calls it for several locks:
--   redis-cli --eval release.lua lock:report , worker-a
--

if redis.call('GET', 'lock:report') == ARGV[1] then
  return redis.call('DEL', 'lock:report')
end
return 0
