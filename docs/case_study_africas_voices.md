# Case Study - Somleng, UNICEF Somalia, Africa's Voices Foundation (AVF)

## Location

[Somalia](https://en.wikipedia.org/wiki/Somalia)

## Preface

This is a technical document about the Somleng deployment for [Africa's Voices Foundation (AVF)](http://www.africasvoices.org/) in conjunction with [UNICEF Somalia](https://www.unicef.org/somalia/). It assumes that the reader has some knowledge about [Somleng](https://github.com/somleng/somleng-project/blob/master/docs/what_is_somleng.md) and [RapidPro](https://community.rapidpro.io/). The document focusses on technology related aspects of the project. This document is Open Source. [Pull requests](https://github.com/somleng/somleng-project/pulls) are welcome. Previous diffs and versions are available [here](https://github.com/somleng/somleng-project/commits/master/docs/case_study_africas_voices.md).

## Introduction

From: [http://rtd.somleng.org/](http://rtd.somleng.org/)

> Returnee households from Dadaab refugee camp in Kenya and vulnerable households in Bay and Bakool received emergency unconditional cash-based transfer assistance package to help them meet their needs during the current drought period. Voice-based messaging is used to share information on the program and inform them of feedback loops.

## Technology

### Stack

1. [Somleng Simple Call Flow Manager (Somleng SCFM)](https://github.com/somleng/somleng-scfm) controls scheduling, queuing, retrying and analysis of outbound calls through [Somleng's REST API](https://github.com/somleng/twilreapi). Somleng SCFM also connects to [RapidPro](https://community.rapidpro.io/) to trigger outbound SMS flows.
2. [RapidPro](https://community.rapidpro.io/) controls SMS flows and handles inbound phone calls received from Somleng.
3. [Somleng](https://github.com/somleng/freeswitch-config) is connected to Shaqodoon which acts as an aggrigator for the Mobile Network Operators (MNOs) in Somalia.
4. The MNOs deliver and receive calls through local mobile networks.

### Hosting

A new instance of Somleng was deployed to [Amazon Web Services (AWS)](https://aws.amazon.com/) for this project, with the intention of reusing the instance later for other projects.

#### AWS Region

Initially Somleng was deployed to AWS (Mumbai, India) because it's the [closest available region to Somalia](https://aws.amazon.com/about-aws/global-infrastructure/). However it was discovered during the deployment that AWS (Mumbai, India) lacks support for some critical infrastructure that Somleng requires for deployment. Specifically the missing infrastructure is support for [Elastic Beanstalk Multi-Container Docker environments](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker_ecs.html) (this still remains undocumented on AWS). After this was discovered Somleng was redeployed to AWS Singapore.

The average [round trip (ping) time](https://en.wikipedia.org/wiki/Ping_(networking_utility)) from the [FreeSWITCH instance](https://github.com/somleng/freeswitch-config) hosted on AWS in Singapore to Shaqodoon's server hosted at [Telesom Tower, Hargeisa, Somaliland](https://www.google.com.kh/maps/place/Telesom+Tower/@9.5589495,44.0667021,20z/data=!4m12!1m6!3m5!1s0x1628bf9a0f0071e9:0x915dbb06d93f5bc!2sTelesom+Tower!8m2!3d9.5590572!4d44.067058!3m4!1s0x1628bf9a0f0071e9:0x915dbb06d93f5bc!8m2!3d9.5590572!4d44.067058?hl=en) is `~450ms`. Initially it was thought that this latency may cause an issue with quality. however after testing we discovered that because the interaction with the callee is non-conversational in nature (a conversation example would be two people talking on the phone together), latency wasn't an issue.

#### Domain

For this project the domain `unicef.io` was purchased with the intention of reusing the domain for additional UNICEF technology related projects. The domain is managed by [AWS Route 53](https://aws.amazon.com/route53/). [Somleng's REST API](https://github.com/somleng/twilreapi) is hosted at [somleng.unicef.io](somleng.unicef.io/).

### Shaqadoon

Somleng is connected to [Shaqodoon](http://shaqodoon.org/technology/) which acts as an aggrigator for the multiple Mobile Network Operators (MNOs) in Somalia. Shaqodoon provides a [SIP](https://en.wikipedia.org/wiki/Session_Initiation_Protocol) endpoint to an [Asterisk](http://www.asterisk.org/) server. Shaqodoon provides one [E1 line](https://en.wikipedia.org/wiki/E-carrier) to each MNO. Each E1 line can support up to 32 simultanous calls. Shaqodoon aggregates the the following MNOs:

1. [Telesom](https://en.wikipedia.org/wiki/Telesom)
2. [Golis](https://en.wikipedia.org/wiki/Golis_Telecom_Somalia)
3. [NationLink](https://en.wikipedia.org/wiki/NationLink_Telecom)
4. [Somtel](https://en.wikipedia.org/wiki/Somtel)
5. [Hormuud](https://en.wikipedia.org/wiki/Hormuud_Telecom)

### Issues and Resolutions

#### Call Throttling

Since Shaqodoon (the aggrigator) only provides one [E1 line](https://en.wikipedia.org/wiki/E-carrier) to each MNO (with each line supporting 32 calls) the customer, Africa's Voices Foundation (AVF) quickly ran into issues relating to call throttling when triggering outbound calls through RapidPro.

If a call is triggered when an E1 line is full, [Somleng's FreeSWITCH instance](https://github.com/somleng/freeswitch-config) receives a `503` [SIP Response Code](https://en.wikipedia.org/wiki/List_of_SIP_response_codes#5xx.E2.80.94Server_Failure_Responses) from Shaqodoon. According to the [Twilio standard](https://www.twilio.com/docs/api/voice/call#call-status-values) Somleng reports this to the client (in this case RapidPro) as a `failed` call. It's then up to the client (RapidPro) to retry the call through Somleng (or not) according the the logic of the application.

Since [RapidPro does not support retrying calls](https://github.com/rapidpro/rapidpro/issues/599), it was decided to bypass RapidPro for triggering outbound calls. Instead of using triggering outbound calls through RapidPro, AVF wrote their own retry logic which connects to [Somleng's REST API](https://github.com/somleng/twilreapi) directly.

AVF ran into some technical issues with their retry logic which resulted in Somleng develping a new new product called [Somleng Simple Call Flow Manager (SCFM)](https://github.com/somleng/somleng-scfm) which is specifically designed for queuing, retrying, scheduling and analysis of calls. AVF now uses Somleng SCFM to automatically retry failed calls.

#### Recording Calls


#### DTMF Tones

#### CIDR



#### Outstanding Issues

## Technology Developed / Improved

* Torasup

## Outcomes

* Somleng SCFM
* Recording
* Documentation

## Cost Savings

See [Real Time Data](http://rtd.somleng.org/) for an up-to-date comparison of cost savings [compared to Twilio](https://www.twilio.com/voice/pricing/so)

## Lessons Learned
