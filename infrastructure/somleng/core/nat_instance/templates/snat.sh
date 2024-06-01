#!/bin/bash -x

# wait for ens6
while ! ip link show dev ens6; do
  sleep 1
done

# NAT Instance Setup
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html#NATInstance

# enable IP forwarding and NAT on ens5 (EIP ENI)
# Forward stateful connections from ens5 to eth6 (responses from the internet)
# Forward any connections from ens6 to eth5 (connections to the internet)
sysctl -q -w net.ipv4.ip_forward=1
/sbin/iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
/sbin/iptables -A FORWARD -i eth5 -o eth6 -m state --state RELATED,ESTABLISHED -j ACCEPT
/sbin/iptables -A FORWARD -i eth6 -o eth5 -j ACCEPT
service iptables save

# wait for network connection
curl --retry 10 http://www.example.com

# re-establish connections
systemctl restart amazon-ssm-agent
