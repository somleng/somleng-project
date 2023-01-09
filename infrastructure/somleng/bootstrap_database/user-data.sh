#!/bin/bash

set -e

yum -y update

# install the version of postgres which matches the restore version
yum -y install postgresql13

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`

AWS_REGION="$(wget --header "X-aws-ec2-metadata-token: $TOKEN" -q -O - http://169.254.169.254/latest/meta-data/placement/region)"
PGPASSWORD=$(aws ssm get-parameter --name ${db_master_password_parameter_name} --with-decryption --output text --query Parameter.Value --region $AWS_REGION)

if [ "${create_db}" = "y" ]
then
  PGPASSWORD=$PGPASSWORD psql --host=${db_host} --username=${db_username} --dbname postgres --command="CREATE DATABASE ${db_name}"
fi

if [ "${restore_db}" = "y" ]
then
  PGPASSWORD=$PGPASSWORD psql --host=${db_host} --username=${db_username} --dbname postgres --command="DROP DATABASE ${db_name}"
  PGPASSWORD=$PGPASSWORD psql --host=${db_host} --username=${db_username} --dbname postgres --command="CREATE DATABASE ${db_name}"
  file_to_restore="${restore_db_from_backup_name}_latest.dump"
  aws s3 cp "s3://backups.somleng.org/db/$file_to_restore" "/tmp/$file_to_restore"
  PGPASSWORD=$PGPASSWORD pg_restore --verbose --clean --no-acl --no-owner --host=${db_host} --username=${db_username} --dbname=${db_name} --port=5432 "/tmp/$file_to_restore"
fi
