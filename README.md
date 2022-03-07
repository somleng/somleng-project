# The Somleng Project

![Somleng](https://github.com/dwilkie/somleng-project/raw/gh-pages/images/talking_in_the_factory.jpg "Credit: Fani Llaurado")

## What is The Somleng Project?

The Somleng Project is a collection of open source telephony tools which can be used to build powerful Voice applications. The goal of the project is to break down the economic and accessibility barriers to building telephony applications. Read more about Somleng on our website at [somleng.org](https://www.somleng.org).

## How can I use it?

Follow the [GETTING STARTED](https://github.com/somleng/somleng-project/blob/master/docs/GETTING_STARTED.md) guide to get Somleng up and running on your local development machine.

## How it works?

The diagram below shows how each component is connected together.

![Somleng-Overview](https://github.com/somleng/somleng-project/raw/master/somleng_overview.png)

### Explanation

On the left hand side, applications such as [RapidPro](https://community.rapidpro.io/), [Somleng SCFM](https://github.com/somleng/somleng-scfm) or your own custom application use [Twilio's libraries](https://www.twilio.com/docs/libraries) to connect to [Somleng's Open Source Implementation of Twilio's REST API](https://www.somleng.org/docs/twilio_api) by updating the endpoint in the helper library from `api.twilio.org` to `api.somleng.org` (or to your own URL running Somleng).

[Somleng](https://github.com/somleng/somleng) internally connects to [SomlengSWITCH](https://github.com/somleng/somleng-switch) which contains an open source TwiML interpreter. SomlengSWITCH then interprets the [TwiML](https://www.twilio.com/docs/voice/twiml) (provided by the connecting application on the left) in order to control the call.

SomlengSWITCH can be connected to carriers, VoIP gateways, SIM Boxes or even GSM modems in order to make or receive calls from the telephone network.

More information on the various components are listed below. More detailed information about each components can be found in the individual project repositories.

### Somleng

[Somleng](https://github.com/somleng/somleng) is an Open Source Cloud Communications Platform as a Service (CPaaS). It contains an [Open Source implementation of Twilio's REST API](https://www.somleng.org/docs/twilio_api) as well as APIs and functionality for Carriers to onboard their own customers.

### SomlengSWITCH

[SomlengSWITCH](https://github.com/somleng/somleng-switch) is a the switching layer for Somleng. Some features include:

* TTS engines
* Open source TwiML parser

### Somleng Simple Call Flow Manager (SCFM)

[Somleng Simple Call Flow Manager (SCFM)](https://github.com/somleng/somleng-scfm) is an application which can be used to connect and process calls through Somleng (or Twilio). It can also be used as an alternative [RapidPro](https://community.rapidpro.io/) for enqueuing calls and handling inbound call flows.

## Deployment

The [infrastructure directory](https://github.com/somleng/somleng-project/tree/master/infrastructure/somleng) contains [Terraform](https://www.terraform.io/) configuration files in order to deploy Somleng to AWS. This repository only contains core infrastructure. Each individual component's infrastructure is in its own repository.

:warning: The current infrastructure of Somleng is rapidly changing as we continue to improve and experiment with new features. We often make breaking changes to the current infrastructure which usually requires some manual migration. We don't recommend that you try to deploy and run your own Somleng stack for production purposes at this stage. Instead consider using our [hosting](#hosting) services.

The core infrastructure in this repository is a dependency of the other components and is shared using [remote state](https://www.terraform.io/language/state/remote).

## Hosting

Chatterbox Solutions offers white-labeled Somleng hosting for Carriers. Currently hosting is in private beta. Please [contact us](mailto:contact@somleng.org?subject=Somleng+Hosting) for more info.

## Who's sponsoring The Somleng Project?

[The Somleng Project](http://www.somleng.org) is among the first 5 start-ups to received investment from the the [UNICEF Innovation Fund](http://www.unicefstories.org/2016/11/14/somleng-open-source-telephony).

## What does Somleng mean?

Somleng (សំឡេង) means Voice in Khmer.

## Investors

[Pitch Deck](https://tinyurl.com/somleng-investordeck)

Special thanks to our investors:

[UNICEF Innovation Fund](https://tinyurl.com/crypto-bridge)
