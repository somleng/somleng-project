resource "aws_eip" "this" {
  domain = "vpc"

  tags = {
    Name = "NAT Instance"
  }
}
