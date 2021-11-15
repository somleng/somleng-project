#!/bin/bash -x

# wait for eth1
while ! ip link show dev eth1; do
  sleep 1
done

# NAT Instance Setup
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html#NATInstance

# enable IP forwarding and NAT on eth1
sysctl -q -w net.ipv4.ip_forward=1
sysctl -q -w net.ipv4.conf.eth1.send_redirects=0
/sbin/iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
service iptables save

# switch the default route to eth1
ip route del default dev eth0

# wait for network connection
curl --retry 10 http://www.example.com

# reestablish connections
systemctl restart amazon-ssm-agent
