#!/bin/bash -x

yum -y update
yum -y install iptables iptables-services jq

# Enable SSM Access

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Get the instance metadata

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
AWS_REGION="$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)"
INSTANCE_ID="$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)"

# attach the ENI
# Retry incase this instance boots before the old one shuts down

retries=60

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

# Update the cloudwatch alarm dimensions to terminate instance if in alarm

describe_alarm_result=$(aws cloudwatch describe-alarms --alarm-names ${cloudwatch_alarm_name} --query 'MetricAlarms[0]' --region $AWS_REGION | jq '{AlarmName,MetricName,Period,EvaluationPeriods,ComparisonOperator,Namespace,Statistic,Threshold}')

aws cloudwatch put-metric-alarm \
  --cli-input-json "$describe_alarm_result" \
  --dimensions "Name=InstanceId,Value=$INSTANCE_ID" \
  --alarm-actions arn:aws:automate:$AWS_REGION:ec2:terminate \
  --region $AWS_REGION

# start SNAT
systemctl enable snat
systemctl start snat
