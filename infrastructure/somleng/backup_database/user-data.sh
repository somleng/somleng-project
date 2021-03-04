#!/bin/bash

yum -y update
amazon-linux-extras install postgresql11 -y

timestamp=$(date +"%Y%m%d%H%M%S")

if [ "${application_name}" = "twilreapi" ]
then
  output_filename="${old_db_name}_$timestamp.dump"
  PGPASSWORD="${old_db_password}" pg_dump -Fc --host=${old_db_host} --username=${old_db_username} --dbname=${old_db_name} --port=5432 > "/tmp/$output_filename"
  aws s3 rm "s3://backups.somleng.org/db/${old_db_name}_latest.dump"
  aws s3 cp "/tmp/$output_filename" "s3://backups.somleng.org/db/$output_filename"
  aws s3 cp "s3://backups.somleng.org/db/$output_filename" "s3://backups.somleng.org/db/${old_db_name}_latest.dump"
fi
