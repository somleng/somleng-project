#!/bin/bash

set -e

yum -y update
amazon-linux-extras install epel

# Get postgres 13 from official sources
tee /etc/yum.repos.d/pgdg.repo<<EOF
[pgdg13]
name=PostgreSQL 13 for RHEL/CentOS 7
baseurl=https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-7-aarch64/
enabled=1
gpgcheck=0
EOF

# install the version of postgres which matches the restore version
yum -y install postgresql13-13.6

AWS_REGION="$(wget -q -O - http://169.254.169.254/latest/meta-data/placement/region)"
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
