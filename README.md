# The Somleng Project

![Somleng](https://github.com/dwilkie/somleng-project/raw/gh-pages/images/talking_in_the_factory.jpg "Credit: Fani Llaurado")

## What is The Somleng Project?

The Somleng Project is a collection of open source telephony tools which can be used to build powerful Voice and SMS applications. The goal of the project is to break down the economic and accessibility barriers to building telephony applications.

## How can I use it?

Here's how to make a phone call through Somleng. Look familiar?

```
$ curl -XPOST https://your-somleng-installation.com/api/2010-04-01/Accounts/{AccountSID}/Calls.json \
    -d "Method=GET" \
    -d "Url=http://demo.twilio.com/docs/voice.xml" \
    -d "To=%2B85512345678" \
    -d "From=%2B85512345679" \
    -u 'your_account_sid:your_auth_token'
```

## Project Resources

The various open source tools that make up The Somleng Project are listed below. More detailed information about each technology can be found in the individual project repositories.

### Twilreapi

[Twilreapi](https://github.com/dwilkie/twilreapi) is an Open Source implementation of [Twilio's REST API](https://www.twilio.com/docs/api/rest). You can use [Twilreapi](https://github.com/dwilkie/twilreapi) to create accounts, enqueue calls and SMS and view your dashboard.

### Somleng-Adhearsion

[Somleng-Adhearsion](https://github.com/dwilkie/somleng) is an [Adhearsion](https://github.com/adhearsion/adhearsion) application which can handle the delivery of outbound calls and the processing of inbound calls. You can connect [Somleng-Adhearsion](https://github.com/dwilkie/somleng) to [Twilreapi](https://github.com/dwilkie/twilreapi) to process your outbound calls and respond to inbound calls.

### Adhearsion-Twilio

[Adhearsion-Twilio](https://github.com/dwilkie/adhearsion-twilio) is an [Adhearsion](https://github.com/adhearsion/adhearsion) Plugin which talks [TwiML](https://www.twilio.com/docs/api/twiml). [Adhearsion-Twilio](https://github.com/dwilkie/adhearsion-twilio) is used in [Somleng-Adhearsion](https://github.com/dwilkie/somleng) in order to process [TwiML](https://www.twilio.com/docs/api/twiml) returned from the client application.

### Somleng FreeSWITCH Configuration

[Somleng FreeSWITCH configuration](https://github.com/dwilkie/freeswitch-config) is a set of [FreeSWITCH](https://freeswitch.org/) configuration optimized for Adhearsion applications. It can be used with to configure your [FreeSWITCH](https://freeswitch.org/) installation to connect to [Somleng-Adhearsion](https://github.com/dwilkie/somleng)

### Somleng-RTD

Real time data collection tool for The Somleng Project. Coming Soon.

### Somleng Demo

A demo application that shows The Somleng Project in action. Coming Soon.

### The Somleng Project Website

The [repository](https://github.com/dwilkie/freeswitch-config) for this website.

## Who's sponsoring The Somleng Project?

Watch this space...

## What does Somleng mean?

Somleng (សំឡេង) means Voice in Khmer.
