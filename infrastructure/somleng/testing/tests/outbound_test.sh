#!/bin/sh

set -eu

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
AWS_PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)

echo "This test will test outbound calls on staging."

read -p "1. Add (or modify) a SIP trunk on Somleng with the following Host IP for outbound dialing: $AWS_PUBLIC_IP. Press any key when done."
read -p "2. Start the SIPp server. In another terminal run the following: sipp -sf ./scenarios/uas.xml -mi $AWS_PUBLIC_IP --key advertised_ip "$AWS_PUBLIC_IP" -trace_msg -trace_err. Press any key when done."
read -p "3. Optionally Start TCP dump. In another terminal run the following: sudo docker run -it --rm --net container:cid nicolaka/netshoot followed by tcpdump -Xvv -i ens5 -s0 -w capture.pcap. Press any key when done."

echo "Enter the Somleng Account SID: "
read somleng_account_sid

echo "Enter the Somleng Auth Token: "
read somleng_auth_token

echo "Enter the from number (e.g. 1294): "
read from

echo "Enter number of calls per minute: "
read calls_per_minute

if ! echo "$calls_per_minute" | grep -Eq '^[0-9]+$' || [ "$calls_per_minute" -le 0 ]; then
  echo "Invalid input. Must be a positive integer."
  exit 1
fi

interval=$(awk "BEGIN { print 60 / $calls_per_minute }")

count=0
while :; do
  count=$((count + 1))
  now=$(date -u +"%Y-%m-%d %H:%M:%SZ")
  printf "[%s] Attempt %d: creating call ... " "$now" "$count"

  response_and_code=$(curl -s -w "\n%{http_code}" -X "POST" "https://api-staging.somleng.org/2010-04-01/Accounts/$somleng_account_sid/Calls.json" \
      -H 'Content-Type: application/x-www-form-urlencoded; charset=utf-8' \
      -u "$somleng_account_sid:$somleng_auth_token" \
      --data-urlencode "Twiml=<Response><Play>https://uploads.open-ews.org/in75y27srkzbagtj94z5ldwsyz3x.mp3</Play></Response>" \
      --data-urlencode "From=$from" \
      --data-urlencode "To=+855715100860")

  http_code=$(echo "$response_and_code" | tail -n1)
  response_body=$(echo "$response_and_code" | head -n -1)

  # Check if successful (200 or 201)
  if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
      sid=$(echo "$response_body" | jq -r '.sid')
      echo "Call created successfully! SID: $sid"
  else
      echo "Call creation failed (HTTP $http_code)"
  fi

  sleep "$interval"
done
