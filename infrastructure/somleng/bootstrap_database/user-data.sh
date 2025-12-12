#!/bin/bash

# Get this data from inside EC2 instance
# TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
# curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/user-data

set -e

dnf update
dnf install -y docker
service docker start

POSTGRES_VERSION=17

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
AWS_REGION="$(wget --header "X-aws-ec2-metadata-token: $TOKEN" -q -O - http://169.254.169.254/latest/meta-data/placement/region)"
PGPASSWORD=$(aws ssm get-parameter --name ${db_master_password_parameter_name} --with-decryption --output text --query Parameter.Value --region $AWS_REGION)

if [ "${create_db}" = "y" ]
then
  sudo docker run --rm -e PGPASSWORD=$PGPASSWORD public.ecr.aws/docker/library/postgres:$POSTGRES_VERSION-alpine psql --host=${db_host} --username=${db_username} --dbname postgres --command="CREATE DATABASE ${db_name}"
fi

if [ "${restore_db}" = "y" ]
then
  workspace="/home/ssm-user/backups"
  file_to_restore="${restore_db_from_backup_name}_latest.dump"

  mkdir -p $workspace
  aws s3 cp "s3://backups.somleng.org/db/$file_to_restore" "$workspace/$file_to_restore"

  sudo docker run --rm -e PGPASSWORD=$PGPASSWORD public.ecr.aws/docker/library/postgres:$POSTGRES_VERSION-alpine psql --host=${db_host} --username=${db_username} --dbname postgres --command="DROP DATABASE ${db_name}"
  sudo docker run --rm -e PGPASSWORD=$PGPASSWORD public.ecr.aws/docker/library/postgres:$POSTGRES_VERSION-alpine psql --host=${db_host} --username=${db_username} --dbname postgres --command="CREATE DATABASE ${db_name}"
  sudo docker run --rm -e PGPASSWORD=$PGPASSWORD public.ecr.aws/docker/library/postgres:$POSTGRES_VERSION-alpine pg_restore --verbose --clean --no-acl --no-owner --host=${db_host} --username=${db_username} --dbname=${db_name} --port=5432 "$workspace/$file_to_restore"
fi
