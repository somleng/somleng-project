resource "aws_network_interface" "this" {
  subnet_id         = var.vpc.public_subnets[0]
  description       = "NAT Instance"
  security_groups   = [aws_security_group.this.id]
  source_dest_check = false

  tags = {
    Name = "NAT Instance"
  }

  lifecycle {
    ignore_changes = [attachment]
  }
}
