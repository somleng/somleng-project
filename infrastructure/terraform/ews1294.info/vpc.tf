resource "aws_vpc" "pin" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "pin-production"
  }
}

resource "aws_subnet" "private-1a" {
  vpc_id            = "${aws_vpc.pin.id}"
  availability_zone = "ap-southeast-1a"
  cidr_block        = "${cidrsubnet(aws_vpc.pin.cidr_block, 8, 3)}"

  tags {
    Name = "production-private-1a"
  }
}

resource "aws_subnet" "private-1b" {
  vpc_id            = "${aws_vpc.pin.id}"
  availability_zone = "ap-southeast-1b"
  cidr_block        = "${cidrsubnet(aws_vpc.pin.cidr_block, 8, 1)}"

  tags {
    Name = "production-private-1c"
  }
}

resource "aws_subnet" "private-1c" {
  vpc_id            = "${aws_vpc.pin.id}"
  availability_zone = "ap-southeast-1c"
  cidr_block        = "${cidrsubnet(aws_vpc.pin.cidr_block, 8, 5)}"

  tags {
    Name = "production-private-1c"
  }
}

resource "aws_subnet" "public-1a" {
  vpc_id            = "${aws_vpc.pin.id}"
  availability_zone = "ap-southeast-1a"
  cidr_block        = "${cidrsubnet(aws_vpc.pin.cidr_block, 8, 2)}"

  tags {
    Name = "production-public-1a"
  }
}

resource "aws_subnet" "public-1b" {
  vpc_id            = "${aws_vpc.pin.id}"
  availability_zone = "ap-southeast-1b"
  cidr_block        = "${cidrsubnet(aws_vpc.pin.cidr_block, 8, 0)}"

  tags {
    Name = "production-public-1b"
  }
}

resource "aws_subnet" "public-1c" {
  vpc_id            = "${aws_vpc.pin.id}"
  availability_zone = "ap-southeast-1c"
  cidr_block        = "${cidrsubnet(aws_vpc.pin.cidr_block, 8, 4)}"

  tags {
    Name = "production-public-1c"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.pin.id}"

  tags {
    Name = "production"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.pin.id}"

  tags {
    Name = "production-public"
  }
}

resource "aws_route" "igw" {
  route_table_id            = "${aws_route_table.public.id}"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.gw.id}"
}

resource "aws_route_table_association" "public-1a" {
  subnet_id      = "${aws_subnet.public-1a.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public-1b" {
  subnet_id      = "${aws_subnet.public-1b.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public-1c" {
  subnet_id      = "${aws_subnet.public-1c.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_eip" "nat_gateway_eip" {
  vpc      = true
}

resource "aws_nat_gateway" "private_gw" {
  allocation_id = "${aws_eip.nat_gateway_eip.id}"
  subnet_id = "${aws_subnet.public-1a.id}"

  tags {
    Name = "production"
  }

  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.pin.id}"

  tags {
    Name = "production-private"
  }
}

resource "aws_route" "nat" {
  route_table_id            = "${aws_route_table.private.id}"
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.private_gw.id}"
}

resource "aws_route_table_association" "private-1a" {
  subnet_id      = "${aws_subnet.private-1a.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private-1b" {
  subnet_id      = "${aws_subnet.private-1b.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private-1c" {
  subnet_id      = "${aws_subnet.private-1c.id}"
  route_table_id = "${aws_route_table.private.id}"
}
