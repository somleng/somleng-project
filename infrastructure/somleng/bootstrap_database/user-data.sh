#!/bin/bash

yum -y update
amazon-linux-extras install postgresql11 -y

if [ "${create_db}" = "y" ]
then
  PGPASSWORD="${db_password}" psql --host=${db_host} --username=${db_username} --dbname postgres --command="CREATE DATABASE ${db_name}"
fi

if [ "${restore_db}" = "y" ]
then
  PGPASSWORD="${db_password}" psql --host=${db_host} --username=${db_username} --dbname postgres --command="DROP DATABASE ${db_name}"
  PGPASSWORD="${db_password}" psql --host=${db_host} --username=${db_username} --dbname postgres --command="CREATE DATABASE ${db_name}"
  file_to_restore="${restore_db_from_backup_name}_latest.dump"
  aws s3 cp "s3://backups.somleng.org/db/$file_to_restore" "/tmp/$file_to_restore"
  PGPASSWORD="${db_password}" pg_restore --verbose --clean --no-acl --no-owner --host=${db_host} --username=${db_username} --dbname=${db_name} --port=5432 "/tmp/$file_to_restore"
fi
