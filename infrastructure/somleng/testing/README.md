# Somleng E2E Integration Tests

This directory contains infrastructure and end-to-end tests for testing Somleng.

It is useful for load testing and recording SIP traces from the customer side.

## Setup

1. Edit `variables.tf` and choose the desired region for testing.
2. Run `terraform apply`
3. Open a SSM session to `somleng-e2e-testing`
4. Run `sudo docker ps`
5. Run `sudo docker exec -it <docker-id> /bin/sh`

## Cleanup

1. Run `terraform destroy`
