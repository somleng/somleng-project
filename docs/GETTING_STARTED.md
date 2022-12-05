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

## Start Somleng's services

Remember to replace `FS_EXTERNAL_SIP_IP` and `FS_EXTERNAL_RTP_IP` with your the local IP of your machine.

```
$ FS_EXTERNAL_SIP_IP=<replace-with-your-local-ip> FS_EXTERNAL_RTP_IP=<replace-with-your-local-ip> docker-compose up
```

## Setup and seed Somleng

Remember to replace `HOST_IP` with your local IP address.

```
$ docker-compose exec -e HOST_IP=<replace-with-your-local-ip> somleng bundle exec rails db:setup
```

You should get the following output:

```
Account SID:           xxxx
Auth Token:            yyyy
Inbound Phone Number:  1234
---------------------------------------------
URL:                   http://my-carrier.app.lvh.me:3000/
Carrier User Email:    johndoe@carrier.com
Carrier User Password: Somleng1234!
Carrier API Key:       zzzz
```

You should be now able to log in to the Somleng dashboard at [http://my-carrier.app.lvh.me:3000](http://my-carrier.app.lvh.me:3000). With the credentials above.

Note: You'll need to setup 2FA after this step. You can use the [Authenticator](https://authenticator.cc/) browser extension if you don't already have another 2FA application.

You can find you Account SID and Auth Token under the [Accounts](http://my-carrier.app.lvh.me:3000/accounts) section of the dashboard.

## Install and configure Linphone

In order to test out Somleng's programmable voice feature on your local machine you'll need a SIP client. We recommend using Linphhone.

1. Install Linphone from [https://www.linphone.org/](https://www.linphone.org/).
2. Configure your SIP account under Preferences -> SIP Accounts. Note you must set your Username to `299221234` (or another valid phone number in Greenland). The SIP address should be automatically filled with your local IP.

![Linphone Account Settings](/docs/images/linphone_acct_settings.png?raw=true "Linphone Account Settings")

3. Configure your network settings under Preferences -> Network Settings. Set both the SIP/UDP and SIP/TCP listening port to `5061`.

![Linphone Network Settings](/docs/images/linphone_network_settings.png?raw=true "Linphone Network Settings")

## Test an outbound call

Use [cURL](https://curl.se/) or your favorite HTTP client, e.g. [Postman](https://www.postman.com/) to initiate an outbound call.

Remember to replace the placeholders with your Account SID and Auth Token. You can set the URL to any URL which returns valid [TwiML](https://www.twilio.com/docs/voice/twiml).

```
curl -X "POST" "http://api.lvh.me:3000/2010-04-01/Accounts/<replace-with-your-account-sid>/Calls" \
     -H 'Content-Type: application/x-www-form-urlencoded; charset=utf-8' \
     -u '<replace-with-your-account-sid>:<replace-with-your-auth-token>' \
     --data-urlencode "Url=https://demo.twilio.com/docs/voice.xml" \
     --data-urlencode "Method=GET" \
     --data-urlencode "To=+299221234" \
     --data-urlencode "From=1294"
```
