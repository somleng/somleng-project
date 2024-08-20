data "aws_region" "this" {}

data "aws_region" "helium" {
  provider = aws.helium
}
