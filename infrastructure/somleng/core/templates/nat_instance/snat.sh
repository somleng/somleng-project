#!/bin/bash -x

# wait for ens6
while ! ip link show dev ens6; do
  sleep 1
done

# NAT Instance Setup
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html#NATInstance

# enable IP forwarding and NAT on ens6
sysctl -q -w net.ipv4.ip_forward=1
sysctl -q -w net.ipv4.conf.ens6.send_redirects=0
/sbin/iptables -t nat -A POSTROUTING -o ens6 -j MASQUERADE
service iptables save

# switch the default route to ens6

GATEWAY=$(ip route | awk '/default/ { print $3 }')
ip route add $GATEWAY dev ens6
ip route add default via $GATEWAY
ip route del default dev ens5

# wait for network connection
curl --retry 10 http://www.example.com

# re-establish connections
systemctl restart amazon-ssm-agent
