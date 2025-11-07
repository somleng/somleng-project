# The Somleng Project

<p align="center">
  <a href="https://www.digitalpublicgoods.net/registry#:~:text=Somleng">
    <img src="https://user-images.githubusercontent.com/667909/181150972-e59a77ab-b657-4893-aef9-d3df1384a506.png" alt="DPG Approved" height="40">
  </a>
</p>

## About this Repository

This repository is the entry point for The Somleng Project. The README links to the individual software components that make up Somleng. The repository also contains the source code for [somleng.org](https://www.somleng.org).

[![Build](https://github.com/somleng/somleng-project/actions/workflows/build.yml/badge.svg)](https://github.com/somleng/somleng-project/actions/workflows/build.yml)

## What is Somleng?

Somleng is the world's only Open Source Telco-as-a-service (TaaS) and Cloud-communications-as-a-service (CPaaS).
With the support of UNICEF, we're helping to save lives by reaching some of the most remote and vulnerable communities around the world. [Learn more](https://www.somleng.org).

> Our vision is a world where communications is accessible to everyone.

You can use Somleng to roll out your own programmable voice and SMS to:

* 🏥 [Save lives](https://www.somleng.org/case_studies.html#early-warning-system-cambodia)
* 🧒🏽 [Improve the lives of children](https://www.somleng.org/case_studies.html#mhealth-unicef-guatemala)
* 🤑 [For fun or profit](https://www.somleng.org/case_studies.html#powering-cpaas-mexico)

## How does it work?

The diagram below shows how each component is connected together.

![Somleng-Overview](https://github.com/somleng/somleng-project/raw/main/somleng_overview.png)

### Explanation

On the left hand side, applications such as [RapidPro](https://community.rapidpro.io/), [OpenEWS](https://github.com/open-ews/open-ews), or your own custom application use [Twilio's libraries](https://www.twilio.com/docs/libraries) to connect to [Somleng's Open Source Implementation of Twilio's REST API](https://www.somleng.org/docs/twilio_api) by updating the endpoint in the helper library from `api.twilio.org` to `api.somleng.org` (or to your own URL running Somleng).

[Somleng](https://github.com/somleng/somleng) then connects to carriers, aggregators, network providers, VoIP gateways, or SMS gateways in order to make or receive calls/SMS from the telephone network via [SomlengSWITCH](https://github.com/somleng/somleng-switch) which interprets the [TwiML](https://www.twilio.com/docs/voice/twiml) (provided by the connecting application on the left) in order to control a call / SMS.

More information on the various components are listed below. More detailed information about each component can be found in the individual project repositories.

### Somleng

[Somleng](https://github.com/somleng/somleng) is an Open Source Cloud Communications Platform as a Service (CPaaS). This is the core engine of Somleng. Some features include:

* An open source implementation of Twilio's REST API for programmable voice and SMS.
* White-label(able) dashboard.

### SomlengSWITCH

[SomlengSWITCH](https://github.com/somleng/somleng-switch) is the low level switching layer for Somleng. Some features include:

* TTS engines
* Open source TwiML parser
* AI Voice Agent

### OpenEWS

[OpenEWS](https://github.com/somleng/open-ews) is world's first Open Source Emergency Warning System Dissemination Dashboard.

## Documentation

Below is a link to the documentation start page.

* 📚 [Documentation](https://www.somleng.org/docs.html)

## Getting Started

Follow the [Getting Started Guide](https://www.somleng.org/docs#getting-started) and run through the tutorials to learn about Somleng.

## Installation

Follow the [Installation](https://www.somleng.org/docs#installation) guide to get Somleng up and running on your local development machine.

## Deployment

The [infrastructure directory](https://github.com/somleng/somleng-project/tree/main/infrastructure/somleng) contains [Terraform](https://www.terraform.io/) configuration files in order to deploy Somleng to AWS. This repository only contains core infrastructure. Each individual component's infrastructure is in its own repository. Some of the infrastructure in this repository is a dependency of the other components and is shared using [remote state](https://www.terraform.io/language/state/remote).

## Hosting

Chatterbox Solutions offers Somleng-as-a-Service for Carriers. Currently this service is in private beta. Please [contact us](mailto:contact@somleng.org?subject=Somleng%20Inquiry&body=Hi%2C%0D%0A%0D%0AWe're%20interested%20in%20using%20your%20hosting%20services.) for more info.

## Connect with the community

You can join at the [Discord](https://discord.gg/QdrKCW2kPx) channel for asking questions about the project or talk about Somleng with other peers.

## Contributing

For carriers, network providers, or anyone who is interested in suggesting features to Somleng, feel free to join us on the [Discord channel](https://discord.gg/QdrKCW2kPx).

Currently we are moving quickly to achieve the goals stated in [our roadmap](#roadmap). While we welcome anyone who wants to contribute to Somleng we have some specific goals which we want to achieve. It's best to reach out to us on the [Discord channel](https://discord.gg/QdrKCW2kPx) first to discuss your ideas before submitting a pull request.

All final decisions about the direction of this project will be decided by the Somleng team.

## Who's sponsoring The Somleng Project?

[The Somleng Project](http://www.somleng.org) is among the first 5 start-ups to received investment from the the [UNICEF Innovation Fund](https://www.unicefventurefund.org/story/somleng-open-source-telephony).

## What does Somleng mean?

Somleng (សំឡេង) means Voice in Khmer.

## Project Resources

* [Stakeholders](https://miro.com/app/board/uXjVOKklTvw=/?invite_link_id=979877928721)
* [Pitch Deck](https://tinyurl.com/somleng-investordeck)
* [Community](https://discord.gg/QdrKCW2kPx)

## Investors

[Pitch Deck](https://tinyurl.com/somleng-investordeck)

Special thanks to our investors:

[UNICEF Innovation Fund](https://tinyurl.com/crypto-bridge)
