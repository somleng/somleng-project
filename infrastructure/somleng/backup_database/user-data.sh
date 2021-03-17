#!/bin/bash

yum -y update
amazon-linux-extras install postgresql11 -y

timestamp=$(date +"%Y%m%d%H%M%S")
output_filename="${db_name}_$timestamp.dump"
PGPASSWORD="${db_password}" pg_dump -Fc --host=${db_host} --username=${db_username} --dbname=${db_name} --port=5432 > "/tmp/$output_filename"
aws s3 rm "s3://backups.somleng.org/db/${db_name}_latest.dump"
aws s3 cp "/tmp/$output_filename" "s3://backups.somleng.org/db/$output_filename"
aws s3 cp "s3://backups.somleng.org/db/$output_filename" "s3://backups.somleng.org/db/${db_name}_latest.dump"
