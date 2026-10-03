# dns6: a different /etc/hosts per namespace

mkdir -p /etc/netns/a
cp /etc/hosts /etc/netns/a/hosts
echo "10.99.0.80 web.lab.test" >>/etc/netns/a/hosts
