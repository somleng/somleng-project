resource "aws_route53_zone" "somleng_org" {
  name = "somleng.org."
}

resource "aws_route53_zone" "internal" {
  name = "internal.somleng.org."

  vpc {
    vpc_id = data.terraform_remote_state.somleng.outputs.vpc.vpc_id
  }
}