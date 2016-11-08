# The Somleng Project

Welcome to project home of The Somleng Project.

## What is The Somleng Project?

The Somleng Project is a collection of open source telephony tools which can be used to build powerful Voice and SMS applications. The goal of the project is to break down the economic and accessibility barriers to building telephony applications.

## What makes up The Somleng Project?

The various open source tools that make up The Somleng Project are listed below. More detailed information about each technology can be found in the individual project repositories.

* [Twilreapi](https://github.com/dwilkie/twilreapi) - An Open Source implementation of [Twilio's REST API](https://www.twilio.com/docs/api/rest) built on [Rails](http://rubyonrails.org/).
* [Somleng-Adhearsion](https://github.com/dwilkie/somleng) - An [Adhearsion](https://github.com/adhearsion/adhearsion) application which handles delivering phone calls.
* [Adhearsion-Twilio](https://github.com/dwilkie/adhearsion-twilio) - An [Adhearsion](https://github.com/adhearsion/adhearsion) Plugin which talks [TwiML](https://www.twilio.com/docs/api/twiml).
* [Adhearsion](https://github.com/adhearsion/adhearsion) - A Ruby framework for building telephony applications.
* [Somleng FreeSWITCH configuration](https://github.com/dwilkie/freeswitch-config) - FreeSWITCH configuration optimized for Somleng.
* [FreeSWITCH](https://freeswitch.org/) - Free multi-protocol softswitch.

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

## Who's sponsoring The Somleng Project?

Watch this space...

## What does Somleng mean?

Somleng (សំឡេង) means Voice in Khmer.
