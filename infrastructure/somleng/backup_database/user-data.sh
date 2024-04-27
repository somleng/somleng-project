#!/bin/bash

# Get this data from inside EC2 instance
# TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
# curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/user-data

set -e

dnf update
dnf install -y docker
service docker start

POSTGRES_VERSION=16

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
AWS_REGION="$(wget --header "X-aws-ec2-metadata-token: $TOKEN" -q -O - http://169.254.169.254/latest/meta-data/placement/region)"
PGPASSWORD=$(aws ssm get-parameter --name ${db_master_password_parameter_name} --with-decryption --output text --query Parameter.Value --region $AWS_REGION)

if [ "${backup_db}" = "y" ]
then
  timestamp=$(date +"%Y%m%d%H%M%S")
  output_filename="${db_name}_$timestamp.dump"
  output_dir="/home/ssm-user/backups"

  mkdir -p $output_dir
  sudo docker run --rm -e PGPASSWORD=$PGPASSWORD public.ecr.aws/docker/library/postgres:$POSTGRES_VERSION-alpine pg_dump -Fc --host=${db_host} --username=${db_username} --dbname=${db_name} --port=5432 > "$output_dir/$output_filename"
  aws s3 rm "s3://backups.somleng.org/db/${db_name}_latest.dump"
  aws s3 cp "$output_dir/$output_filename" "s3://backups.somleng.org/db/$output_filename"
  aws s3 cp "s3://backups.somleng.org/db/$output_filename" "s3://backups.somleng.org/db/${db_name}_latest.dump" --copy-props none
else
  echo "sudo docker run -it --rm -e PGPASSWORD=$PGPASSWORD public.ecr.aws/docker/library/postgres:$POSTGRES_VERSION-alpine psql --host=${db_host} --username=${db_username} --dbname=${db_name} --port=5432" > "$output_dir/psql.command"
fi
