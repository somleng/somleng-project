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

resource "aws_security_group" "cross_region" {
  name   = "${var.identifier}-cross-region"
  vpc_id = var.region.vpc.vpc_id

  ingress {
    from_port   = var.database_port
    to_port     = var.database_port
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/8"]
  }

  tags = {
    Name = "aurora-${local.database_identifier}-cross-region"
  }
}
