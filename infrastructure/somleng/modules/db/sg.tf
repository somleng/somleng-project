resource "aws_security_group" "this" {
  name   = var.identifier
  vpc_id = var.region.vpc.vpc_id

  ingress {
    from_port = var.database_port
    to_port   = var.database_port
    protocol  = "TCP"
    self      = true
  }

  tags = {
    Name = "aurora-${local.database_identifier}"
  }
}
