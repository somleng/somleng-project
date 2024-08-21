#!/bin/bash

# Get this data from inside EC2 instance
# TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
# curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/user-data

set -e

dnf update
dnf install -y docker
service docker start

unzip /opt/testing/test_files.zip -d /opt/testing/tests
docker build -t "testing:latest" /opt/testing
docker run --rm --net=host -d testing:latest tail -f /dev/null
