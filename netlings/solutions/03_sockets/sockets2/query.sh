# sockets2: ss filters

ss -Htln '( sport >= :8000 and sport <= :8999 )'
