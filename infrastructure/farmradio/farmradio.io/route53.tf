resource "aws_route53_zone" "farmradio_io" {
  name = "farmradio.io."
}

resource "aws_route53_zone" "farmradio_io_internal" {
  name = "internal.farmradio.io."

  vpc {
    vpc_id = data.terraform_remote_state.somleng.outputs.vpc.vpc_id
  }
}