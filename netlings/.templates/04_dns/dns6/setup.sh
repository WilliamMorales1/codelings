# dns6: a different /etc/hosts per namespace
#
# `ip netns exec NAME ...` does one more thing besides switching network
# namespace: for every file in /etc/netns/NAME/ it bind-mounts that file over
# the one in /etc. So /etc/netns/a/hosts becomes /etc/hosts, but only for
# commands run via `ip netns exec a`. That is how you give one namespace its
# own resolv.conf or hosts file.
#
# The check sets up namespaces a and b, both using the lab DNS server, where
# web.lab.test is 10.53.0.80. Test clients in namespace a must see the staging
# copy instead:
#     ip netns exec a getent hosts web.lab.test  -> 10.99.0.80
#     ip netns exec b getent hosts web.lab.test  -> 10.53.0.80   (unchanged)
#
# Your task: this version changes it for everybody. Scope it to a.
# (/etc is private to the sandbox, so write whatever you like there.)

echo "10.99.0.80 web.lab.test" >>/etc/hosts
