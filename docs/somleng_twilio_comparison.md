# Somleng vs Twilio Comparison

## Preface

This document assumes that you have some basic knowledge about what Somleng and Twilio are and how they work. If not, please go ahead and read about [Somleng](https://github.com/somleng/somleng-project/blob/master/docs/what_is_somleng.md) and [Twilio](https://github.com/somleng/somleng-project/blob/master/docs/what_is_twilio.md) first.

## Disclaimer

I'm the founder of Somleng and I [authored](https://github.com/somleng/somleng-project/commit/11e5eca86be878e81aaa020c63c5baa657503b5d) this document. This document is intended to be as [objective](https://www.google.com.kh/search?&q=define+objective) as possible when comparing Somleng with Twilio. If you see anything that's too subjective please open a [Pull Request](https://github.com/somleng/somleng-project/pulls).

## Feature Comparison

| Feature                   | Somleng  | Twilio   |
| :------------------------:|:--------:| :-------:|
| Features                  | Less     | More     |
| Voice                     | Yes      | Yes      |
| SMS                       | No*      | Yes      |
| Video                     | No*      | Yes      |
| Open Source               | Yes      | No       |
| PaaS                      | No       | Yes      |
| Ease of Getting Started   | Harder   | Easier   |
| Support Packages          | Yes      | Yes      |
| Customizable              | Yes      | No       |
| Deploy to own Servers     | Yes      | No       |
| Deal with your own telcos | Yes      | No       |
| Pricing                   | Free**   | Not Free |

* *Not yet but could be implemented
* **Somleng is free but you [may](https://github.com/somleng/somleng-project/blob/master/docs/case_study_africas_voices.md) or [may not](https://github.com/somleng/somleng-project/blob/master/docs/case_study_ews.md) need to pay your local telco or aggregator.

## Reasons why some people choose **Twilio** instead Somleng

### Easier to get started

Because [Twilio is a PaaS (Platform as a Service)](https://en.wikipedia.org/wiki/Twilio) it's relatively simple to get something up an running. Just [sign up](https://www.twilio.com/try-twilio) for an account, purchase a number, write some [TwiML](https://www.twilio.com/docs/api/twiml), use the [REST API](https://www.twilio.com/docs/api/rest) and you're away.

Somleng on the other hand is Open Source so you have to install it yourself. Detailed technical documentation is available for deploying Somleng (for example [this guide](https://github.com/somleng/twilreapi/blob/master/docs/DEPLOYMENT.md) for deploying the REST API to AWS) however

### More complete features

Some applications rely on features that Somleng does not yet support, for example SMS or Video calling. For applications that solely rely on features that are not supported by Somleng, Twilio is may be the best option. For applications that rely on a combination of features that are already supported by Somleng and that are not you may consider using a hybrid of both Twilio and Somleng.

## Reasons why some people choose **Somleng** instead of Twilio

### Want full control

Somleng let's you have full control over your stack.

### Have your own relationship with a Telco

### Twilio's too expensive

### Twilio doesn't work in your country

### Twilio's quality is poor in your country

### You need a local number for inbound calls which Twilio does not have in your country
