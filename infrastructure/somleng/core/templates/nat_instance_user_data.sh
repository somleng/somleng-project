#!/bin/bash

yum -y update

# Enable SSM Access

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# NAT Instance Setup
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html#NATInstance

sysctl -w net.ipv4.ip_forward=1
/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
yum install iptables-services
service iptables save

# Disable Src/Dest check
# https://stackoverflow.com/a/57507735

EC2_INSTANCE_ID="$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)"
AWS_REGION="$(wget -q -O - http://169.254.169.254/latest/meta-data/placement/region)"
aws ec2 modify-instance-attribute --no-source-dest-check --instance-id $EC2_INSTANCE_ID --region $AWS_REGION

# Attach EIP

EIP_ALLOCATION_ID=$(aws ec2 describe-tags --region $AWS_REGION --filters "Name=resource-id,Values=$EC2_INSTANCE_ID" "Name=key,Values=EipAllocationId" --output=text --query="Tags[0].Value")
aws ec2 associate-address --region $AWS_REGION --instance-id $EC2_INSTANCE_ID --allocation-id $EIP_ALLOCATION_ID --allow-reassociation
