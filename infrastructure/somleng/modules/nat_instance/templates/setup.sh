#!/bin/bash -x

# Get this data from inside EC2 instance
# TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
# curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/user-data

yum -y update
yum -y install iptables iptables-services jq

# Enable SSM Access

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Get the instance metadata

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
AWS_REGION="$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)"
INSTANCE_ID="$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)"

retries=60

# Associate the EIP

for ((i=0; i<retries; i++)); do
  aws ec2 associate-address \
    --instance-id $INSTANCE_ID \
    --allocation-id "${eip_allocation_id}"

  [[ $? -eq 0 ]] && break

  echo "Failed to associate EIP. Pausing 10s then retrying"

  sleep 10
done

aws ec2 modify-instance-attribute \
  --instance-id $INSTANCE_ID \
  --no-source-dest-check

# attach the ENI
# Retry incase this instance boots before the old one shuts down

for ((i=0; i<retries; i++)); do
  aws ec2 attach-network-interface \
    --region $AWS_REGION \
    --instance-id $INSTANCE_ID \
    --device-index 1 \
    --network-interface-id "${eni_id}"

  [[ $? -eq 0 ]] && break

  echo "Failed to attach ENI. Pausing 10s then retrying"

  sleep 10
done

# start SNAT
systemctl enable snat
systemctl start snat
