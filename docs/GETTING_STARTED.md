# Getting Started

This guide is intended to give you instant gratification.

## Pull the latest images

```
$ sudo docker-compose pull
```

## Setup Somleng's REST API

Run the following command and note down the output.

```
$ sudo docker-compose run twilreapi_web /bin/bash -c './bin/rails db:setup'
```

## Start Somleng

```
$ sudo docker-compose up
```

## Make a call

### Initiate a call with CURL

[Make a call](https://www.twilio.com/docs/api/voice/making-calls?code-sample=code-make-an-outbound-call&code-language=curl&code-sdk-version=json). Replace `{AccountSID}` and `{AuthToken}` with your User Account SID and Auth Token output when [seeding the database](#seed-the-database). Note this won't actually call anyone. In order to see

```
$ curl -XPOST http://localhost:3000/api/2010-04-01/Accounts/{AccountSID}/Calls.json \
    --data-urlencode "Method=GET" \
    --data-urlencode "Url=http://demo.twilio.com/docs/voice.xml" \
    --data-urlencode "To=+85512345678" \
    --data-urlencode "From=+855202101" \
    -u '{AccountSID}:{AuthToken}'
```

### Answer the call with linphone

```
$ sudo docker-compose exec linphone /bin/bash -c 'linphonecsh generic answer'
```

### Hangup the call

```
$ sudo docker-compose exec linphone /bin/bash -c 'linphonecsh generic terminate'
```
