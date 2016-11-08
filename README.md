# Somleng Project

Welcome to the home of the Somleng Project.

## What is the Somleng Project?

The Somleng Project is a set of open source telephony tools which can be used to build powerful Voice and SMS applications.

## Give me an example already!

Ok, here's how to make a phone call with Somleng. Look familiar?

```
$ curl -XPOST https://your-somleng-installation.com/api/2010-04-01/Accounts/{AccountSID}/Calls.json \
    -d "Method=GET" \
    -d "Url=http://demo.twilio.com/docs/voice.xml" \
    -d "To=%2B85512345678" \
    -d "From=%2B85512345679" \
    -u 'your_account_sid:your_auth_token'
```

## What will I find on this page?

Resources to the various Open Source Repositores that make up Somleng are listed here:

* [Twilreapi](https://github.com/dwilkie/twilreapi) - An Open Source implementation of [Twilio's REST API](https://www.twilio.com/docs/api/rest) built on [Rails](http://rubyonrails.org/).
* [Somleng-Adhearsion](https://github.com/dwilkie/somleng) - An [Adhearsion](https://github.com/adhearsion/adhearsion) application which handles delivering phone calls via SIP.
* [Adhearsion-Twilio](https://github.com/dwilkie/adhearsion-twilio) - An [Adhearsion](https://github.com/adhearsion/adhearsion) Plugin which talks [TwiML](https://www.twilio.com/docs/api/twiml)
* [Adhearsion](https://github.com/adhearsion/adhearsion) - A Ruby framework for building telephony applications.
* [Somleng FreeSWITCH configuration](https://github.com/dwilkie/freeswitch-config) - FreeSWITCH configuration optimized for Somleng.
* [FreeSWITCH](https://freeswitch.org/) - Free multi-protocol softswitch.

## What does Somleng mean?

Somleng (សំឡេង) means Voice in Khmer.
