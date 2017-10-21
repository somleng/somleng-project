# Getting Started

This guide is intended to give you instant gratification.

## Pull the latest images

```
$ sudo docker-compose pull
```

## Setup Somleng's REST API

```
$ sudo docker-compose run web /bin/bash -c './bin/rails db:setup'
```

## Start Somleng's Services

```
$ sudo docker-compose up
```

## Make a call

In another terminal...

### Get the Account SID and Auth Token

```
$ IFS=: read ACCOUNT_SID AUTH_TOKEN <<< $(sudo docker-compose run -e FORMAT=basicauth web /bin/bash -c './bin/rails db:seed')
$ echo "Account SID: $ACCOUNT_SID" && echo "Auth Token: $AUTH_TOKEN"
```

### Initiate a call with CURL

```
$ sudo docker-compose run -e ACCOUNT_SID=$ACCOUNT_SID -e AUTH_TOKEN=$AUTH_TOKEN curl /bin/sh -c 'curl http://web:3000/api/2010-04-01/Accounts/$ACCOUNT_SID/Calls.json --data-urlencode "Method=GET" --data-urlencode "Url=http://demo.twilio.com/docs/voice.xml" --data-urlencode "To=+85510202101" --data-urlencode "From=1234" -u "$ACCOUNT_SID:$AUTH_TOKEN"'
```

### Answer the call with linphone

```
$ sudo docker-compose exec linphone /bin/bash -c 'linphonecsh generic answer'
```

### Hangup the call

```
$ sudo docker-compose exec linphone /bin/bash -c 'linphonecsh generic terminate'
```
