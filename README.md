# The Somleng Project

![Somleng](https://github.com/dwilkie/somleng-project/raw/gh-pages/images/talking_in_the_factory.jpg "Credit: Fani Llaurado")

## What is The Somleng Project?

The Somleng Project is a collection of open source telephony tools which can be used to build powerful Voice applications. The goal of the project is to break down the economic and accessibility barriers to building telephony applications. Read more about Somleng on our website at [somleng.org](https://www.somleng.org).

## How can I use it?

Follow the [GETTING STARTED](https://github.com/somleng/somleng-project/blob/master/docs/GETTING_STARTED.md) guide to get started.

You can also connect Somleng to Call Flow Managers such as [RapidPro](https://www.rapidpro.io/) or [Somleng Simple Call Flow Manager (Somleng SCFM)](https://github.com/somleng/somleng-scfm) or connect it your own application using any of [Twilio's Open Source libraries](https://www.twilio.com/docs/libraries).

## Project Resources

The various open source tools that make up The Somleng Project are listed below. More detailed information about each technology can be found in the individual project repositories.

The diagram below shows how each technology is connected together. Depending on your specific needs you may choose to use all or just some of the open source tools described below.

![Somleng-Overview](https://docs.google.com/drawings/d/e/2PACX-1vSMYTP8Rk_N_I6BWrc4QWhRl6EaAOEyWJTzeXRoKmPWzdqIiQyzSH9YWz3wzCin2H227GT0CSkkop9K/pub?w=1478&h=728)

### Twilreapi

[Twilreapi](https://github.com/somleng/twilreapi) is an Open Source implementation of [Twilio's REST API](https://www.twilio.com/docs/api/rest). You can use [Twilreapi](https://github.com/somleng/twilreapi) to enqueue outbound calls.

### Somleng-Adhearsion

[Somleng-Adhearsion](https://github.com/somleng/somleng-adhearsion) is an [Adhearsion](https://github.com/adhearsion/adhearsion) application which handles the delivery of outbound calls and the processing of inbound calls. [Somleng-Adhearsion](https://github.com/somleng/somleng-adhearsiono) is connected to [Twilreapi](https://github.com/somleng/twilreapi) to process your outbound calls and respond to inbound calls.

### Somleng FreeSWITCH Configuration

[Somleng FreeSWITCH configuration](https://github.com/somleng/freeswitch-config) is a set of [FreeSWITCH](https://freeswitch.org/) configuration optimized for Somleng. It can be used to configure your [FreeSWITCH](https://freeswitch.org/) installation to connect to [Somleng-Adhearsion](https://github.com/somleng/somleng-adhearsion).

### Somleng Simple Call Flow Manager (SCFM)

[Somleng Simple Call Flow Manager (SCFM)](https://github.com/somleng/somleng-scfm) can be used to enqueue, throttle, update, and process calls through Somleng (or Twilio). [Somleng SCFM](https://github.com/somleng/somleng-scfm) can be used as an alternative [RapidPro](https://community.rapidpro.io/) for enqueuing calls and handling inbound call flows.

## Who's sponsoring The Somleng Project?

[The Somleng Project](http://www.somleng.org) is among the first 5 start-ups to received investment from the the [UNICEF Innovation Fund](http://www.unicefstories.org/2016/11/14/somleng-open-source-telephony).

## What does Somleng mean?

Somleng (សំឡេង) means Voice in Khmer.
