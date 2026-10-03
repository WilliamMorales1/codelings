# sockets5: who is holding that port?
#
# "address already in use" / "what is listening on 7002?" is a daily
# question. `ss -p` adds the owning process to every line, like
#     users:(("netlings",pid=41,fd=3))
# (as a normal user you only see your own processes; root sees all).
#
# The check starts several servers, some on confusingly similar ports, then
# runs this script. It must print ONLY the PID (just the number) of the process
# listening on TCP port 7002.
#
# The attempt below prints whole lines, and grep for "7002" also matches
# other things. Use an ss filter instead, then cut the pid out.

ss -tlnp | grep 7002
