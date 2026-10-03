# sockets5: who is holding that port?

ss -Htlnp 'sport = :7002' | sed -E 's/.*pid=([0-9]+).*/\1/'
