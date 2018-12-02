import boto3
import botocore
import os

from datetime import datetime

ec2_client = boto3.client('ec2')
asg_client = boto3.client('autoscaling')

def lambda_handler(event, context):
  log("Received Event: {}".format(event))

  if event["detail-type"] != os.environ['EVENT_DETAIL_TYPE']:
    return

  log("Processing Event")

  instance_id = event['detail']['EC2InstanceId']
  lifecycle_hook_name = event['detail']['LifecycleHookName']
  autoscaling_group_name = event['detail']['AutoScalingGroupName']

  in_service_instance_id = get_in_service_instance_id(AutoScalingGroupName)
  tag_allocation_id = get_instance_tag(in_service_instance_id, os.environ.get('EIP_ALLOCATION_ID_TAG_KEY'))
  allocation_id = tag_allocation_id or os.environ['EIP_ALLOCATION_ID']

  associate_address(in_service_instance_id)

  complete_lifecycle_action_success(lifecycle_hook_name, autoscaling_group_name, instance_id)

def get_in_service_instance_id(asg_group_name):
  response = asg_client.describe_auto_scaling_groups(
    AutoScalingGroupNames=[asg_group_name]
  )

  in_service_instances = filter(lambda x: x["LifecycleState"] == "InService", response['AutoScalingGroups'][0]['Instances'])

  return in_service_instances[0]["InstanceId"] if in_service_instances else None

def get_instance_tag(instance_id, tag_key):
  if tag_key is None:
    return None

  instance_details = ec2_client.describe_instances(InstanceIds=[instance_id])
  tags = instance_details["Reservations"][0]["Instances"][0]["Tags"]
  filtered_tags = filter(lambda t: t["Key"] == tag_key, tags)

  return filtered_tags[0]["Value"] if filtered_tags else None

def associate_address(instance_id, allocation_id):
  response = ec2_client.associate_address(
    AllocationId=allocation_id,
    InstanceId=instance_id
  )

  log("Associated IP Address with: {}. Response: {}".format(instance_id, response))

def remove_unassociated_addresses():
  filters = [{'Name': 'domain', 'Values': ['vpc']}]

  response = ec2_client.describe_addresses(Filters=filters)
  unassocated_addresses = filter(lambda x: "InstanceId" not in x, response["Addresses"])

  for address in unassocated_addresses:
    response = ec2_client.release_address(
      AllocationId=address["AllocationId"]
    )

def complete_lifecycle_action_success(hookname, groupname, instance_id):
  try:
    asg_client.complete_lifecycle_action(
      LifecycleHookName=hookname,
      AutoScalingGroupName=groupname,
      InstanceId=instance_id,
      LifecycleActionResult='CONTINUE'
    )
    log("Lifecycle hook CONTINUEd for: {}".format(instance_id))
  except botocore.exceptions.ClientError as e:
    log("Error completing life cycle hook for instance {}: {}".format(instance_id, e.response['Error']))
    log('{"Error": "1"}')

def complete_lifecycle_action_failure(hookname,groupname,instance_id):
  try:
    asg_client.complete_lifecycle_action(
      LifecycleHookName=hookname,
      AutoScalingGroupName=groupname,
      InstanceId=instance_id,
      LifecycleActionResult='ABANDON'
    )
    log("Lifecycle hook ABANDONed for: {}".format(instance_id))
  except botocore.exceptions.ClientError as e:
    log("Error completing life cycle hook for instance {}: {}".format(instance_id, e.response['Error']))
    log('{"Error": "1"}')

def log(error):
  print('{}Z {}'.format(datetime.utcnow().isoformat(), error))
