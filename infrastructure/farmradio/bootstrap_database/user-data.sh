#!/bin/bash

yum -y update
amazon-linux-extras install postgresql11 -y
PGPASSWORD="${db_password}" psql --host=${db_host} --username=${db_username} --dbname postgres --command="CREATE DATABASE ${db_name}"