# Getting Started

This guide is intended to get you up and running with Somleng on your machine.

## Prerequisites

Install [Docker](https://docs.docker.com/engine/installation), [docker-compose](https://docs.docker.com/compose/install/) [git](https://git-scm.com/downloads) and [linphone](https://www.linphone.org/technical-corner/linphone)

## Clone the repository using git

```
$ git clone https://github.com/somleng/somleng-project --depth 1 && cd somleng-project
```

Or download `docker-compose.yml` manually [here](https://raw.githubusercontent.com/somleng/somleng-project/master/docker-compose.yml)

## Pull the latest images

```
$ docker-compose pull
```

## Setup and seed Twilreapi

```
$ docker-compose exec twilreapi bundle exec rails db:setup
```

Note down the output for later.

```
Account SID:          xxxxxxxxxxxxxxxx
Auth Token:           yyyyyyyyyyyyyyyy
Inbound Phone Number: 1234
```

## Start Somleng's services

Remember to replace `FS_EXTERNAL_SIP_IP` and `FS_EXTERNAL_RTP_IP` with your the local IP of your machine.

```
$ FS_EXTERNAL_SIP_IP=<replace-with-your-local-ip> FS_EXTERNAL_RTP_IP=<replace-with-your-local-ip> docker-compose up
```

## Configure Linphone

1. Install Linphone
2. Configure your SIP account under Preferences -> SIP Accounts. Note you must set your Username to `299221234` (or another valid phone number in Greenland). The SIP address should be automatically filled with your local IP.

![Linphone Account Settings](/images/linphone_acct_settings.png?raw=true "Linphone Account Settings")

3. Configure your network settings under Preferences -> Network Settings. Set both the SIP/UDP and SIP/TCP listening port to `5061`.

![Linphone Network Settings](/images/linphone_network_settingns.png?raw=true "Linphone Network Settings")

## Test an inbound call

Using Linphone make a call to `1234@<you-local-ip-address>`

## Test an outbound call with cURL

Or use your favourite HTTP client.

Remember to replace the placeholders with your Account SID and Auth Token. You can set the URL to any URL which returns TwiML.

```
curl -X "POST" "http://localhost:3000/2010-04-01/Accounts/<replace-with-your-account-sid>/Calls" \
     -H 'Content-Type: application/x-www-form-urlencoded; charset=utf-8' \
     -u '<replace-with-your-account-sid>:<replace-with-your-auth-token>' \
     --data-urlencode "Url=https://demo.twilio.com/docs/voice.xml" \
     --data-urlencode "Method=GET" \
     --data-urlencode "To=+299221234" \
     --data-urlencode "From=1294"
```
